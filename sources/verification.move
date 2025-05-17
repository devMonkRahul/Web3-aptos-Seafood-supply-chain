module seafood_addr::verification {
    use std::string::String;
    use std::signer;
    use std::vector;
    use aptos_framework::timestamp;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;

    // Error codes
    const ENOT_AUTHORIZED: u64 = 1;
    const EVERIFIER_NOT_FOUND: u64 = 2;
    const ECERTIFICATION_NOT_FOUND: u64 = 3;

    // Certification types
    const CERT_SUSTAINABLE_FISHING: u8 = 1;
    const CERT_QUALITY_STANDARD: u8 = 2;
    const CERT_ORGANIC: u8 = 3;

    struct Verifier has store {
        address: address,
        name: String,
        certification_type: u8,
        active: bool,
    }

    struct Certification has store {
        id: u64,
        verifier: address,
        product_id: u64,
        certification_type: u8,
        issue_date: u64,
        expiry_date: u64,
        active: bool,
    }

    struct CertificationEvent has store, drop {
        certification_id: u64,
        product_id: u64,
        verifier: address,
        certification_type: u8,
        timestamp: u64,
        is_revocation: bool,
    }

    struct VerificationRegistry has key {
        verifiers: vector<Verifier>,
        certifications: vector<Certification>,
        event_handle: EventHandle<CertificationEvent>,
        next_certification_id: u64,
    }

    public fun initialize(account: &signer) {
        assert!(signer::address_of(account) == @seafood_addr, ENOT_AUTHORIZED);
        
        if (!exists<VerificationRegistry>(signer::address_of(account))) {
            move_to(account, VerificationRegistry {
                verifiers: vector::empty(),
                certifications: vector::empty(),
                event_handle: account::new_event_handle<CertificationEvent>(account),
                next_certification_id: 0,
            });
        };
    }

    public fun register_verifier(
        account: &signer,
        name: String,
        certification_type: u8,
    ) acquires VerificationRegistry {
        assert!(signer::address_of(account) == @seafood_addr, ENOT_AUTHORIZED);
        
        let registry = borrow_global_mut<VerificationRegistry>(@seafood_addr);
        let verifier = Verifier {
            address: signer::address_of(account),
            name,
            certification_type,
            active: true,
        };
        vector::push_back(&mut registry.verifiers, verifier);
    }

    public fun issue_certification(
        account: &signer,
        product_id: u64,
        certification_type: u8,
        validity_period: u64,
    ) acquires VerificationRegistry {
        let registry = borrow_global_mut<VerificationRegistry>(@seafood_addr);
        let verifier_addr = signer::address_of(account);
        
        // Verify the verifier
        let i = 0;
        let len = vector::length(&registry.verifiers);
        let found = false;
        
        while (i < len) {
            let verifier = vector::borrow(&registry.verifiers, i);
            if (verifier.address == verifier_addr && verifier.certification_type == certification_type && verifier.active) {
                found = true;
                break
            };
            i = i + 1;
        };
        assert!(found, EVERIFIER_NOT_FOUND);

        // Create certification
        let now = timestamp::now_seconds();
        let certification = Certification {
            id: registry.next_certification_id,
            verifier: verifier_addr,
            product_id,
            certification_type,
            issue_date: now,
            expiry_date: now + validity_period,
            active: true,
        };

        vector::push_back(&mut registry.certifications, certification);

        event::emit_event(&mut registry.event_handle, CertificationEvent {
            certification_id: registry.next_certification_id,
            product_id,
            verifier: verifier_addr,
            certification_type,
            timestamp: now,
            is_revocation: false,
        });

        registry.next_certification_id = registry.next_certification_id + 1;
    }

    public fun revoke_certification(
        account: &signer,
        certification_id: u64,
    ) acquires VerificationRegistry {
        let registry = borrow_global_mut<VerificationRegistry>(@seafood_addr);
        let i = 0;
        let len = vector::length(&registry.certifications);
        
        while (i < len) {
            let certification = vector::borrow_mut(&mut registry.certifications, i);
            if (certification.id == certification_id) {
                assert!(certification.verifier == signer::address_of(account), ENOT_AUTHORIZED);
                certification.active = false;

                event::emit_event(&mut registry.event_handle, CertificationEvent {
                    certification_id,
                    product_id: certification.product_id,
                    verifier: certification.verifier,
                    certification_type: certification.certification_type,
                    timestamp: timestamp::now_seconds(),
                    is_revocation: true,
                });
                return
            };
            i = i + 1;
        };
        abort ECERTIFICATION_NOT_FOUND
    }

    #[view]
    public fun verify_certification(certification_id: u64): (u64, address, u8, u64, u64, bool) acquires VerificationRegistry {
        let registry = borrow_global<VerificationRegistry>(@seafood_addr);
        let i = 0;
        let len = vector::length(&registry.certifications);
        
        while (i < len) {
            let certification = vector::borrow(&registry.certifications, i);
            if (certification.id == certification_id) {
                return (
                    certification.product_id,
                    certification.verifier,
                    certification.certification_type,
                    certification.issue_date,
                    certification.expiry_date,
                    certification.active,
                )
            };
            i = i + 1;
        };
        abort ECERTIFICATION_NOT_FOUND
    }
} 