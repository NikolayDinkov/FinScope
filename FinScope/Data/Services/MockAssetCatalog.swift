import Foundation

struct MockAssetCatalog {
    static func generate() -> [MockAsset] {
        var assets: [MockAsset] = []

        let sectors = ["Technology", "Healthcare", "Finance", "Energy", "Consumer", "Industrial", "Materials"]

        // ~700 stocks: 100 per sector
        let stockPrefixes: [String: [String]] = [
            "Technology": ["TK", "SW", "CY", "DG", "NX", "QP", "VR", "AI", "CL", "IO"],
            "Healthcare": ["HC", "MD", "PH", "BT", "GN", "RX", "LB", "WL", "VS", "TH"],
            "Finance": ["FN", "BK", "CP", "IN", "WM", "LN", "TR", "EQ", "MG", "FD"],
            "Energy": ["EN", "OL", "GS", "SL", "WN", "HY", "NR", "PW", "FU", "EG"],
            "Consumer": ["CM", "RT", "FD", "AP", "HM", "LX", "MK", "SH", "BR", "GD"],
            "Industrial": ["MF", "AE", "CN", "DF", "HV", "LG", "MT", "PR", "RL", "TN"],
            "Materials": ["MM", "CH", "ST", "GL", "PM", "AL", "IR", "CU", "ZN", "TI"]
        ]

        let stockNames: [String: [String]] = [
            "Technology": ["Technologies", "Software", "Cyber", "Digital", "Nexus", "Quantum", "Virtual", "Intelligence", "Cloud", "Ionic"],
            "Healthcare": ["Health", "Medical", "Pharma", "Biotech", "Genomics", "Remedy", "Labs", "Wellness", "Vision", "Therapeutics"],
            "Finance": ["Financial", "Bancorp", "Capital", "Insurance", "Wealth", "Lending", "Trust", "Equity", "Mortgage", "Funding"],
            "Energy": ["Energy", "Oil", "Gas", "Solar", "Wind", "Hydro", "Nuclear", "Power", "Fuel", "Electric"],
            "Consumer": ["Commerce", "Retail", "Foods", "Apparel", "Home", "Luxury", "Market", "Shop", "Brands", "Goods"],
            "Industrial": ["Manufacturing", "Aerospace", "Construction", "Defense", "Heavy", "Logistics", "Metals", "Precision", "Rail", "Turbine"],
            "Materials": ["Mining", "Chemical", "Steel", "Glass", "Polymer", "Aluminum", "Iron", "Copper", "Zinc", "Titanium"]
        ]

        for sector in sectors {
            let prefixes = stockPrefixes[sector]!
            let names = stockNames[sector]!
            for i in 0..<100 {
                let prefixIdx = i / 10
                let suffix = i % 10
                let ticker = "\(prefixes[prefixIdx])\(suffix)"
                let name = "\(names[prefixIdx]) \(sectorSuffix(i))"
                let basePrice = deterministicPrice(ticker: ticker, min: 5, max: 500)
                assets.append(MockAsset(
                    name: name,
                    ticker: ticker,
                    type: .stock,
                    sector: sector,
                    basePrice: basePrice
                ))
            }
        }

        // ~150 bonds
        let bondIssuers = ["US Treasury", "Corp AA", "Corp A", "Corp BBB", "Muni", "Intl Govt", "Corp HY", "Agency", "TIPS", "Zero Coupon",
                           "Floating Rate", "Convert", "Covered", "Green Bond", "Sovereign"]
        for i in 0..<150 {
            let issuerIdx = i / 10
            let suffix = i % 10
            let ticker = "BD\(String(format: "%03d", i))"
            let name = "\(bondIssuers[issuerIdx]) Bond \(suffix + 1)"
            let basePrice = deterministicPrice(ticker: ticker, min: 90, max: 110)
            assets.append(MockAsset(
                name: name,
                ticker: ticker,
                type: .bond,
                sector: "Fixed Income",
                basePrice: basePrice
            ))
        }

        // ~150 ETFs
        let etfThemes = ["S&P 500 Index", "Total Market", "Growth", "Value", "Dividend", "Small Cap", "Mid Cap", "International", "Emerging Markets", "Bond Aggregate",
                         "Real Estate", "Commodity", "Tech Sector", "Health Sector", "Energy Sector"]
        for i in 0..<150 {
            let themeIdx = i / 10
            let suffix = i % 10
            let ticker = "EF\(String(format: "%03d", i))"
            let name = "\(etfThemes[themeIdx]) ETF \(suffix + 1)"
            let basePrice = deterministicPrice(ticker: ticker, min: 20, max: 300)
            assets.append(MockAsset(
                name: name,
                ticker: ticker,
                type: .etf,
                sector: "Diversified",
                basePrice: basePrice
            ))
        }

        return assets
    }

    private static func sectorSuffix(_ index: Int) -> String {
        let suffixes = ["Corp", "Inc", "Ltd", "Group", "Holdings", "Systems", "Solutions", "Partners", "Global", "Intl"]
        return suffixes[index % suffixes.count]
    }

    private static func deterministicPrice(ticker: String, min: Int, max: Int) -> Decimal {
        var hash: UInt64 = 5381
        for char in ticker.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }
        let range = UInt64(max - min)
        let cents = hash % (range * 100)
        let dollars = Decimal(min) + Decimal(cents) / 100
        return dollars.rounded(scale: 2)
    }
}
