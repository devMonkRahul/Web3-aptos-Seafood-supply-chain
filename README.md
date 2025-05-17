# SeaChain - Transparent Seafood Supply Chain on Aptos

SeaChain is a decentralized application (dApp) built on the Aptos blockchain that enables transparent tracking of seafood products from catch to consumer. The project aims to improve supply chain transparency, ensure sustainable fishing practices, and provide consumers with verifiable information about their seafood products.

## Features

- **Product Registration**: Record detailed information about seafood catches including species, weight, location, and date
- **Supply Chain Tracking**: Monitor product movement through different stages (caught, processed, shipped, delivered)
- **Temperature Monitoring**: Log and track temperature data throughout the supply chain
- **Certification System**: Issue and verify certifications for sustainable fishing, quality standards, and organic practices
- **QR Code Integration**: Generate and scan QR codes for easy product tracking
- **Real-time Updates**: Track product status and location updates in real-time
- **Blockchain Verification**: All data is stored on the Aptos blockchain for immutability and transparency

## Smart Contracts

The project consists of two main smart contracts:

### Product Contract (`sources/product.move`)
- Handles product registration and tracking
- Manages product state transitions
- Records temperature logs
- Emits events for supply chain updates

### Verification Contract (`sources/verification.move`)
- Manages verifier registration
- Issues and tracks certifications
- Handles certification verification
- Supports multiple certification types (Sustainable Fishing, Quality Standard, Organic)

## Technology Stack

- **Blockchain**: Aptos
- **Smart Contract Language**: Move
- **Frontend**: React with TypeScript
- **UI Framework**: Chakra UI
- **Wallet Integration**: Aptos Wallet Adapter
- **Additional Tools**: QR Code Generation, React Router

## Prerequisites

- [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli)
- [Node.js](https://nodejs.org/) (v16 or higher)
- [NPM](https://www.npmjs.com/) or [Yarn](https://yarnpkg.com/)
- [Git](https://git-scm.com/)
- An Aptos-compatible wallet (e.g., Petra, Martian)

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd seachain
   ```

2. Install Move dependencies and compile contracts:
   ```bash
   aptos move compile
   ```

3. Install frontend dependencies:
   ```bash
   cd frontend
   npm install
   ```

4. Start the development server:
   ```bash
   npm start
   ```

## Smart Contract Deployment

1. Configure your Aptos account:
   ```bash
   aptos init
   ```

2. Update the `Move.toml` file with your account address

3. Deploy the contracts:
   ```bash
   aptos move publish
   ```

## Usage

### For Fishers
1. Connect your Aptos wallet
2. Register new catches with detailed information
3. Log temperature data
4. Transfer products to processors

### For Processors/Distributors
1. Verify received products
2. Update product status
3. Log processing details
4. Transfer products to next supply chain participant

### For Certifiers
1. Register as a verifier
2. Issue certifications for products
3. Manage and revoke certifications

### For Consumers
1. Scan product QR codes
2. View complete supply chain history
3. Verify product certifications
4. Check temperature logs

## Project Structure

```
seachain/
├── sources/                 # Move smart contracts
│   ├── product.move        # Product tracking contract
│   └── verification.move   # Certification contract
├── frontend/               # React frontend application
│   ├── src/
│   │   ├── components/     # Reusable UI components
│   │   ├── pages/         # Main application pages
│   │   └── utils/         # Utility functions
│   └── public/            # Static assets
└── Move.toml              # Move package configuration
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

- All smart contracts have been designed with security best practices
- Access control mechanisms are in place for critical functions
- Event emission for important state changes
- Input validation and error handling

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Project Link: [https://github.com/yourusername/seachain](https://github.com/yourusername/seachain)

## Acknowledgments

- Aptos Labs for the blockchain platform
- Move language developers
- React and Chakra UI teams
- The sustainable fishing community 
