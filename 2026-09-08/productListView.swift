//
//  EmployeeList.swift
//  swiftUIDemo
//
//  Created by user302999 on 9/8/26.
//

import SwiftUI

struct productList: View{
    
    @State private var products: [Product] = []
    
    
    
    var body: some View{
        NavigationStack{ //
            List(products){ emp in
                NavigationLink("Name: \(emp.name), Color: \(emp.color)", value: emp)
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self ){
                selectedItem in
                productDetails(product: selectedItem)
            }
            .toolbar{
                Button(action:{}){
                    Image(systemName: "plus")
                        .accessibilityLabel("add new product")
                }
            }
        }
        
        .task{
            loadData()
        }
    }
    
    

    
    
    
    func loadData(){
        products = [
            Product(id: 101, name: "Milk", productNumber:"th101", color: "White", listPrice:4.25),
            Product(id: 102, name: "Apple", productNumber:"th102", color: "Green", listPrice:1.25),
            Product(id: 103, name: "Bread", productNumber:"th103", color: "Brown", listPrice:3.75),
            Product(id: 104, name: "Candle", productNumber:"th104", color: "Red", listPrice:6.50),
        ]
    }
    
}

#Preview {
    productList()
}
