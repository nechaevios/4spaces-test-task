import Foundation

//MARK: - Models

/// Product Model
struct Product {
    let id: String
    let name: String
    let producer: String
}

/// Additional Storage Model
struct ProductStorageData {
    let product: Product
    let available: Int
}

// MARK: - Product Hashable extension

extension Product: Hashable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//MARK: - Shop Protocol

protocol Shop {
    /**
     Adds a new product object to the Shop.
     - Parameter product: product to add to the Shop
     - Returns: false if the product with same id already exists in the Shop, true – otherwise.
     */
    func addNewProduct(product: Product) -> Bool
    
    /**
     Deletes the product with the specified id from the Shop.
     - Returns: true if the product with same id existed in the Shop, false – otherwise.
     */
    func deleteProduct(id: String) -> Bool
    
    /**
     - Returns: 10 product names containing the specified string.
     If there are several products with the same name, producer's name is added to product's name in the format "<producer> - <product>",
     otherwise returns simply "<product>".
     */
    func listProductsByName(searchString: String) -> Set<String>
    
    /**
     - Returns: 10 product names whose producer contains the specified string,
     result is ordered by producers.
     */
    func listProductsByProducer(searchString: String) -> [String]
}

// MARK: - Shop Impl

final class ShopImpl: Shop {
    
    private var storage = Set<Product>()
    
    func addNewProduct(product: Product) -> Bool {
        storage.insert(product).0
    }
    
    func deleteProduct(id: String) -> Bool {
        let product = Product(id: id, name: "", producer: "")
        guard storage.remove(product) == nil else { return true }
        return false
    }
    
    func listProductsByName(searchString: String) -> Set<String> {
        let filteredProducts = storage.filter { $0.name.contains(searchString) }
        let names = generateNames(from: filteredProducts)

        let limitedResult = Set(names.prefix(10))
        return limitedResult
    }
    
    func listProductsByProducer(searchString: String) -> [String] {
        let filteredProducts = storage.filter { $0.producer.contains(searchString) }
            .sorted(by: { $0.id < $1.id })
            .map { $0.name }
        
        let limitedResult = Array(filteredProducts.prefix(10))
        return limitedResult
    }
}

// MARK: - Supplement Methods

extension ShopImpl {
    
    /// Generate Set of product names
    /// - Parameter filteredProducts: products filtered by name
    /// - Returns: Set of product names
    private func generateNames(from filteredProducts: Set<Product>) -> Set<String> {
        var names = Set<String>()
        for product in filteredProducts {
            let productsWithSameName = filteredProducts.filter { $0.name == product.name }
            let productStorageData = ProductStorageData(product: product, available: productsWithSameName.count)
            let productName = generateNameForProduct(basedOn: productStorageData)
            names.insert(productName)
        }
        
        return names
    }
    
    /// Return product name based on .available count
    /// - Parameter storageData: ProductStorageData. Contains current product and Int of products whit same .name in storage
    /// - Returns: String. Generated Long OR Short name
    private func generateNameForProduct(basedOn storageData: ProductStorageData) -> String {
        if storageData.available > 1 {
            return generateLongName(for: storageData.product)
        }
        
        return generateShortName(for: storageData.product)
    }
    
    /// Generates product short name based on .name data
    /// - Parameter product: product entity
    /// - Returns: String
    private func generateShortName(for product: Product) -> String {
        product.name
    }
    
    /// Generates product long name based on .produces and .name data
    /// - Parameter product: product entity
    /// - Returns: String
    private func generateLongName(for product: Product) -> String {
        "\(product.producer) - \(product.name)"
    }
}

// MARK: - Tests

func test(lib: Shop) {
    assert(!lib.deleteProduct(id: "1"))
    assert(lib.addNewProduct(product: Product(id: "1", name: "1", producer: "Lex")))
    assert(!lib.addNewProduct(product: Product(id: "1", name: "any name because we check id only", producer: "any producer")))
    assert(lib.deleteProduct(id: "1"))
    assert(lib.addNewProduct(product: Product(id: "3", name: "Some Product3", producer: "Some Producer2")))
    assert(lib.addNewProduct(product: Product(id: "4", name: "Some Product1", producer: "Some Producer3")))
    assert(lib.addNewProduct(product: Product(id: "2", name: "Some Product2", producer: "Some Producer2")))
    assert(lib.addNewProduct(product: Product(id: "1", name: "Some Product1", producer: "Some Producer1")))
    assert(lib.addNewProduct(product: Product(id: "5", name: "Other Product5", producer: "Other Producer4")))
    assert(lib.addNewProduct(product: Product(id: "6", name: "Other Product6", producer: "Other Producer4")))
    assert(lib.addNewProduct(product: Product(id: "7", name: "Other Product7", producer: "Other Producer4")))
    assert(lib.addNewProduct(product: Product(id: "8", name: "Other Product8", producer: "Other Producer4")))
    assert(lib.addNewProduct(product: Product(id: "9", name: "Other Product9", producer: "Other Producer4")))
    assert(lib.addNewProduct(product: Product(id: "10", name: "Other Product10", producer: "Other Producer4")))
    assert(lib.addNewProduct(product: Product(id: "11", name: "Other Product11", producer: "Other Producer4")))
    
    var byNames: Set<String> = lib.listProductsByName(searchString: "Product")
    assert(byNames.count == 10)
    
    byNames = lib.listProductsByName(searchString: "Some Product")
    assert(byNames.count == 4)
    assert(byNames.contains("Some Producer3 - Some Product1"))
    assert(byNames.contains("Some Product2"))
    assert(byNames.contains("Some Product3"))
    assert(!byNames.contains("Some Product1"))
    assert(byNames.contains("Some Producer1 - Some Product1"))
    
    var byProducer: [String] = lib.listProductsByProducer(searchString: "Producer")
    assert(byProducer.count == 10)
    
    byProducer = lib.listProductsByProducer(searchString: "Some Producer")
    assert(byProducer.count == 4)
    assert(byProducer[0] == "Some Product1")
    assert(byProducer[1] == "Some Product2" || byProducer[1] == "Some Product3")
    assert(byProducer[2] == "Some Product2" || byProducer[2] == "Some Product3")
    assert(byProducer[3] == "Some Product1")
}

test(lib: ShopImpl())
