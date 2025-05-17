module seafood_addr::product {
    use std::string::String;
    use std::signer;
    use std::vector;
    use aptos_framework::timestamp;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;
    
    // Error codes
    const ENOT_AUTHORIZED: u64 = 1;
    const EPRODUCT_NOT_FOUND: u64 = 2;
    const EINVALID_STATE_TRANSITION: u64 = 3;

    // Product status enum
    const STATUS_CAUGHT: u8 = 0;
    const STATUS_PROCESSED: u8 = 1;
    const STATUS_SHIPPED: u8 = 2;
    const STATUS_DELIVERED: u8 = 3;

    struct ProductInfo has store {
        id: u64,
        species: String,
        weight: u64,
        catch_location: String,
        catch_date: u64,
        fisher_id: address,
        current_holder: address,
        status: u8,
        temperature_log: vector<u64>,
    }

    struct ProductEvent has store, drop {
        id: u64,
        event_type: u8,
        timestamp: u64,
        previous_holder: address,
        new_holder: address,
    }

    struct ProductRegistry has key {
        products: vector<ProductInfo>,
        event_handle: EventHandle<ProductEvent>,
        next_product_id: u64,
    }

    public fun initialize(account: &signer) {
        assert!(signer::address_of(account) == @seafood_addr, ENOT_AUTHORIZED);
        
        if (!exists<ProductRegistry>(signer::address_of(account))) {
            move_to(account, ProductRegistry {
                products: vector::empty(),
                event_handle: account::new_event_handle<ProductEvent>(account),
                next_product_id: 0,
            });
        };
    }

    public fun register_product(
        account: &signer,
        species: String,
        weight: u64,
        catch_location: String,
    ) acquires ProductRegistry {
        let registry = borrow_global_mut<ProductRegistry>(@seafood_addr);
        let product = ProductInfo {
            id: registry.next_product_id,
            species,
            weight,
            catch_location,
            catch_date: timestamp::now_seconds(),
            fisher_id: signer::address_of(account),
            current_holder: signer::address_of(account),
            status: STATUS_CAUGHT,
            temperature_log: vector::empty(),
        };

        vector::push_back(&mut registry.products, product);
        
        event::emit_event(&mut registry.event_handle, ProductEvent {
            id: registry.next_product_id,
            event_type: STATUS_CAUGHT,
            timestamp: timestamp::now_seconds(),
            previous_holder: @0x0,
            new_holder: signer::address_of(account),
        });

        registry.next_product_id = registry.next_product_id + 1;
    }

    public fun transfer_product(
        from: &signer,
        to: address,
        product_id: u64,
        new_status: u8,
    ) acquires ProductRegistry {
        let registry = borrow_global_mut<ProductRegistry>(@seafood_addr);
        let i = 0;
        let len = vector::length(&registry.products);
        
        while (i < len) {
            let product = vector::borrow_mut(&mut registry.products, i);
            if (product.id == product_id) {
                assert!(product.current_holder == signer::address_of(from), ENOT_AUTHORIZED);
                assert!(new_status > product.status, EINVALID_STATE_TRANSITION);
                
                let old_holder = product.current_holder;
                product.current_holder = to;
                product.status = new_status;

                event::emit_event(&mut registry.event_handle, ProductEvent {
                    id: product_id,
                    event_type: new_status,
                    timestamp: timestamp::now_seconds(),
                    previous_holder: old_holder,
                    new_holder: to,
                });
                return
            };
            i = i + 1;
        };
        abort EPRODUCT_NOT_FOUND
    }

    public fun log_temperature(
        account: &signer,
        product_id: u64,
        temperature: u64,
    ) acquires ProductRegistry {
        let registry = borrow_global_mut<ProductRegistry>(@seafood_addr);
        let i = 0;
        let len = vector::length(&registry.products);
        
        while (i < len) {
            let product = vector::borrow_mut(&mut registry.products, i);
            if (product.id == product_id) {
                assert!(product.current_holder == signer::address_of(account), ENOT_AUTHORIZED);
                vector::push_back(&mut product.temperature_log, temperature);
                return
            };
            i = i + 1;
        };
        abort EPRODUCT_NOT_FOUND
    }

    #[view]
    public fun get_product_info(product_id: u64): (String, u64, String, u64, address, address, u8) acquires ProductRegistry {
        let registry = borrow_global<ProductRegistry>(@seafood_addr);
        let i = 0;
        let len = vector::length(&registry.products);
        
        while (i < len) {
            let product = vector::borrow(&registry.products, i);
            if (product.id == product_id) {
                return (
                    product.species,
                    product.weight,
                    product.catch_location,
                    product.catch_date,
                    product.fisher_id,
                    product.current_holder,
                    product.status,
                )
            };
            i = i + 1;
        };
        abort EPRODUCT_NOT_FOUND
    }
} 