// ============================================================
// MODULE 4: Swift Programming Fundamentals
// LAB — PNC Banking Domain Model
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// OVERVIEW
// You are building the Swift data model layer for the PNC Mobile
// Banking application. This layer will be carried forward into
// Modules 6, 7, and 8 as the foundation of the real application.
//
// Every type you define here uses the Swift features from all
// three days of this module. Take time to read the full spec
// before writing any code.
//
// ESTIMATED TIME: 90–120 minutes
//
// ============================================================
// LAB SPEC
// ============================================================
//
// You will build five interconnected Swift types:
//
//   1. TransactionType enum
//   2. TransactionStatus enum
//   3. Transaction struct
//   4. Account class
//   5. AccountAnalytics struct
//
// And three protocols:
//
//   A. Summarizable       — any type that can produce a summary string
//   B. AccountOperations  — deposit, withdraw, transfer
//   C. AnalyticsProvider  — compute basic financial metrics
//
// The lab ends with an error handling system and a generic
// result reporting function that ties everything together.
//
// Read each section completely before implementing it.
// ============================================================

import Foundation


// ============================================================
// SECTION 1: Enumerations
// ============================================================

// TODO 1A: TransactionType
// Conform to: String, CaseIterable, Codable
// Cases:     credit, debit, transfer, fee
// Add computed property: isExpense: Bool
//   → true for .debit and .fee, false otherwise

enum TransactionType: String, CaseIterable, Codable{
    case credit
    case debit
    case transfer
    case fee
    var isExpense:Bool{
        switch self{
            case.debit, .fee:
                return true
        case .credit, .transfer:
                return false
    }
    }
}


// TODO 1B: TransactionStatus
// Conform to: String, Codable
// Cases:     pending, completed, failed, cancelled
// Add computed property: isTerminal: Bool
//   → true for .completed, .failed, .cancelled
//   → false for .pending (can still change)

enum TransactionStatus: String, Codable{
    case pending
    case completed
    case failed
    case cancelled
    var isTerminal:Bool{
        switch self{
        case .completed, .failed, .cancelled:
            return true
        case .pending:
            return false
        }
    }
}



// ============================================================
// SECTION 2: Transaction Struct
// ============================================================

// TODO 2: Define struct Transaction conforming to:
//   Identifiable, Codable, Equatable, Hashable, Summarizable (see Section 4A)
//
// Stored properties:
//   id: String                (unique identifier, default to UUID().uuidString)
//   date: Date
//   amount: Double            (always positive — type determines direction)
//   description: String
//   type: TransactionType
//   status: TransactionStatus (default: .completed)
//   category: String?
//   merchantName: String?
//
// Computed properties:
//   formattedAmount: String
//     → "-$X.XX" for expenses (type.isExpense == true)
//     → "+$X.XX" for income/credit
//
//   formattedDate: String
//     → Use DateFormatter with dateStyle: .medium, timeStyle: .short
//
//   resolvedCategory: String
//     → Returns category if non-nil, "Uncategorized" otherwise
//
// Custom initializer (all params except id, status, category, merchantName
// should be required; the rest should have defaults):
//   init(date:amount:description:type:status:category:merchantName:)


struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable{
    let id:String
    let date:Date
    let amount:Double
    var description:String
    let type:TransactionType
    var status: TransactionStatus = .completed
    let category: String?
    let merchantName: String?
    
    var formattedAmount:String{
            var prefix = ""
        if type.isExpense{
                 prefix = "-"
            }else{
                 prefix = "+"
            }
            let formatted = String(format:"%.2f", abs(amount))
            return "\(prefix)$\(formatted)"
            }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    var resolvedCategory:String{
        if let cat = category{
            return cat
        }
        return "Uncategorized"
    }
    
    init(date:Date,amount:Double,description:String, type:TransactionType, status:TransactionStatus, category:String? = nil, merchantName:String? = nil){
        
        self.id = UUID().uuidString
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    
        
    }
    var summary:String{
        "Description: \(description), amount: \(formattedAmount), date:\(formattedDate) category: \(resolvedCategory) Status \(status)"
     }
    
}




// ============================================================
// SECTION 3: Account Class
// ============================================================

// TODO 3A: Define protocol AccountOperations (see Section 4B)
// before defining Account, because Account will conform to it.
// (Define the protocol in Section 4B, then add conformance to Account here)

// TODO 3B: Define class BankAccount conforming to:
//   Identifiable, AccountOperations, Summarizable
//
// Stored properties:
//   id: String
//   accountNumber: String
//   accountType: String          (e.g., "CHECKING", "SAVINGS")
//   nickname: String?
//   var balance: Double
//   var availableBalance: Double
//   let currency: String         (default "USD")
//   let isActive: Bool           (default true)
//   var transactions: [Transaction]
//
// Computed properties:
//   displayName: String          → nickname if non-nil, else accountType.capitalized
//   maskedAccountNumber: String  → "****" + last 4 digits
//   formattedBalance: String     → "$X.XX"
//   recentTransactions: [Transaction]  → last 5, sorted by date descending
//   pendingCount: Int            → count of transactions with status .pending
//
// Designated initializer:
//   init(id:accountNumber:accountType:nickname:initialBalance:currency:isActive:)
//
// Implement AccountOperations (see Section 4B for the protocol requirements).
// Use the AccountError enum from Section 4C.
//
// Also add:
//   func addTransaction(_ transaction: Transaction)
//     → appends to transactions AND updates balance:
//       if transaction.type.isExpense: balance -= transaction.amount
//       else:                          balance += transaction.amount
//       Update availableBalance to match balance.


class BankAccount: Identifiable,AccountOperations, Summarizable{
    let id: String
    let accountNumber:String
    let accountType:String
    let nickname:String?
    var balance:Double
    var availableBalance:Double
    let currency:String
    let isActive:Bool
    var transactions:[Transaction]
    
    var displayName:String{
        if let name = nickname{
            return name
        }
        return accountType.capitalized
    }
    
    var maskedAccountNumber:String{
        let lastFour = String(accountNumber.suffix(4))
        return "****\(lastFour)"
    }
    
    var formattedBalance:String{
        return "\(String(format: "$%.2f",balance))"
    }
    var recentTransactions:[Transaction]{
        return Array(transactions.suffix(5).reversed())
    }
    var pendingCount:Int{
        var count = 0
        for transaction in transactions{
            if transaction.status == .pending{
                count += 1
            }
        }
    
        return count
    }
    
    init(id:String, accountNumber:String, accountType:String, nickname:String?, initialBalance: Double, currency:String, isActive:Bool){
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = initialBalance
        self.availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
        self.transactions = []
    }
    
 
    func deposit(amount: Double) throws {
        guard isActive else {
            throw AccountOperationsError.accountInactive
        }
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
            
        balance += amount
        availableBalance = balance
    }

    func withdraw(amount: Double) throws {
        guard isActive else {
            throw AccountOperationsError.accountInactive
        }
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        guard balance >= amount else {
            throw AccountOperationsError.insufficientFunds(available: balance, required: amount)
        }
       
            
        balance -= amount
        availableBalance = balance
    }

    func transfer(amount: Double, to destination: BankAccount) throws {
        guard self.id != destination.id else {
            throw AccountOperationsError.transferToSameAccount
        }
        
        try withdraw(amount: amount)
            
        do {
            try destination.deposit(amount: amount)
        } catch {
            
            balance += amount
            availableBalance = balance
            throw error
        }
    }
    

    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        if transaction.type.isExpense{
            balance -= transaction.amount
        }else{
            balance += transaction.amount
        }
        availableBalance = balance
    }
    var summary: String {
        return "BankAccount #\(accountNumber), ID: \(id). Owned by \(displayName). Balance: \(String(format: "$%.2f",balance)) account type: \(accountType)."

    }
    
    
}



// ============================================================
// SECTION 4: Protocols
// ============================================================

// TODO 4A: Summarizable protocol
//   Required: var summary: String { get }
//   Default implementation via extension: func printSummary() — prints summary

protocol Summarizable{
    var summary:String{get}
    func printSummary()
}

extension Summarizable{
   func printSummary(){
        print(summary)
    }
    
}

// TODO 4B: AccountOperations protocol
//   func deposit(amount: Double) throws
//   func withdraw(amount: Double) throws
//   func transfer(amount: Double, to destination: BankAccount) throws
//
// These methods throw AccountOperationsError (define in Section 4C).


protocol AccountOperations{
    func deposit(amount:Double) throws
    func withdraw(amount:Double) throws
    func transfer(amount:Double, to:BankAccount) throws
}


// TODO 4C: AccountOperationsError enum conforming to LocalizedError
// Cases:
//   invalidAmount
//   insufficientFunds(available: Double, required: Double)
//   accountInactive
//   transferToSameAccount
//   dailyLimitExceeded(limit: Double)
//
// Each case should have a meaningful errorDescription.


enum AccountOperationsError: LocalizedError{
    case invalidAmount
    case insufficientFunds(available:Double,required:Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit:Double)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount."
        case .insufficientFunds(let available, let required):
            return "Insufficient funds. Available: \(available), Required: \(required)."
        case .accountInactive:
            return "Account is inactive."
        case .transferToSameAccount:
            return "Cannot transfer to the same account."
        case .dailyLimitExceeded(limit: let limit):
            return "Daily limit exceeded. Limit: \(limit)."
        }
    }
}


// ============================================================
// SECTION 5: Analytics
// ============================================================

// TODO 5A: AnalyticsProvider protocol
//   var totalCredits: Double { get }
//   var totalDebits: Double { get }
//   var netFlow: Double { get }         // credits - debits
//   var largestTransaction: Transaction? { get }
//   func monthlyTotal(month: Int, year: Int) -> Double
//   func transactionsByCategory() -> [String: [Transaction]]
protocol AnalyticsProvider{
    var totalCredits:Double{get}
    var totalDebits:Double{get}
    var netFlow:Double{get}
    var largestTransaction:Transaction?{get}
    func monthlyTotal(month:Int,year:Int)->Double
    func transactionsByCategory()->[String: [Transaction]]
}

// TODO 5B: AccountAnalytics struct
// Stored property: transactions: [Transaction]
// Conform to AnalyticsProvider.
// Implement each requirement.
//
// Tips:
//   totalCredits: use .filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
//   transactionsByCategory: group by resolvedCategory using a Dictionary
//     (hint: use Dictionary(grouping:by:))
//   monthlyTotal: filter by Calendar.current month/year components and sum expense amounts

struct AccountAnalytics:AnalyticsProvider{
    var transactions:[Transaction]
    var totalCredits: Double {
        transactions.filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    var totalDebits: Double {
        transactions.filter { $0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    var netFlow: Double{
        totalCredits - totalDebits
    }
    var largestTransaction: Transaction?{
        transactions.max(by: { $0.amount < $1.amount})
    }
    func monthlyTotal(month: Int, year: Int) -> Double {
        let calendar = Calendar.current
        var total = 0.0
        for transaction in transactions {
            let transMonth = calendar.component(.month, from: transaction.date)
            let transYear = calendar.component(.year, from: transaction.date)
            if(transMonth == month && transYear == year){
                if transaction.type.isExpense{
                   total += transaction.amount
                }
            }
        }
        
        return total

    }
    func transactionsByCategory() -> [String : [Transaction]] {
        Dictionary(grouping: transactions, by: {$0.resolvedCategory } )
    }
}
// ============================================================
// SECTION 6: Generic Result Reporter
// ============================================================

// TODO 6: Write a generic function:
//   func reportResults<T: Summarizable>(_ items: [T], title: String)
//
// It should:
//   1. Print a header line: "=== [title] ==="
//   2. Print the item count: "[N] items"
//   3. Call printSummary() on each item
//   4. Print a footer: "=== End of [title] ==="
//
// The function must work for any type conforming to Summarizable —
// including both Transaction and BankAccount.

func reportResults<T: Summarizable>(_ items: [T], title:String){
    print("=== \(title) ===")
    print("\(items.count) items")
    items.forEach{$0.printSummary()}
    
    print("=== End of \(title) ===")
}

// ============================================================
// SECTION 7: INTEGRATION TEST — Tie it all together
// ============================================================

// TODO 7: Write a function named runlabDemo() that does the following:

// 7A: Create at least two BankAccount instances:
//   - A checking account with $3,500 initial balance
//   - A savings account with $12,000 initial balance

// 7B: Create at least five Transaction instances across different types
//   and add them to the checking account using addTransaction(_:)
//   Include: one credit, two debits, one fee, one transfer
//   Verify the balance updates correctly after each addition.

// 7C: Demonstrate error handling:
//   - Try to withdraw more than the available balance → catch insufficientFunds
//   - Try to deposit a negative amount → catch invalidAmount
//   - Try to transfer to the same account → catch transferToSameAccount
//   Print the localized error description for each caught error.

// 7D: Create an AccountAnalytics instance with the checking account's transactions.
//   Print:
//   - Total credits
//   - Total debits
//   - Net flow
//   - The description and amount of the largest transaction
//   - The transactions grouped by category (print each category and count)

// 7E: Call reportResults with the checking account's transactions, title: "Checking Transactions"
//   Call reportResults with [checkingAccount, savingsAccount], title: "All Accounts"

// 7F: Demonstrate value vs. reference semantics:
//   Copy one Transaction (struct) into a new variable. Modify the copy's description.
//   Show the original is unchanged.
//   Assign the checking account (class) to a new variable. Deposit $100 through the alias.
//   Show both variables reflect the updated balance.

// TODO: Call runlabDemo() at the bottom of the file.
func runlabDemo(){
    let checkingAccount = BankAccount(id: "checkingAccount", accountNumber: "acct01", accountType: "Checking", nickname: "John Doe", initialBalance: 3_500 , currency: "USD", isActive: true)
    let savingsAccount = BankAccount(id: "savingsAccount", accountNumber: "acct02", accountType: "Savings", nickname: nil, initialBalance: 12_000, currency: "USD", isActive: true)
    
    let creditTx = Transaction(date: Date(), amount: 1500.00, description: "Payroll", type: .credit, status: .completed, category: "Income")
    let debitTx1 = Transaction(date: Date(), amount: 25.22, description: "Starbucks", type: .debit, status: .completed, category: "Dining")
    let debitTx2 = Transaction(date: Date(), amount: 84.50, description: "Groceries", type: .debit, status: .completed, category: "Groceries")
    let feeTx = Transaction(date: Date(), amount: 12.00, description: "Monthly Fee", type: .fee, status: .completed, category: "Fees")
    let transferTx = Transaction(date: Date(), amount: 200.00, description: "Transfer In", type: .transfer, status: .completed, category: "Transfer")
    checkingAccount.addTransaction(creditTx)
    print("Balance: \(checkingAccount.formattedBalance)")
    checkingAccount.addTransaction(debitTx1)
    print("Balance: \(checkingAccount.formattedBalance)")
    checkingAccount.addTransaction(debitTx2)
    print("Balance: \(checkingAccount.formattedBalance)")
    checkingAccount.addTransaction(feeTx)
    print("Balance: \(checkingAccount.formattedBalance)")
    checkingAccount.addTransaction(transferTx)
    print("Balance: \(checkingAccount.formattedBalance)")
    
    
    
    do{
        try checkingAccount.withdraw(amount: 5_000_000)
    }catch let error as AccountOperationsError{
        print("Caught: \(error.localizedDescription)")
    }catch{
        print(error)
    }
    
    do {
        try checkingAccount.deposit(amount: -50.0)
    } catch let error as AccountOperationsError {
        print("Caught: \(error.localizedDescription)")
    } catch {
        print("Unexpected error: \(error.localizedDescription)")
    }

    // 3. Try to transfer to the same account → catch transferToSameAccount
    do {
        try checkingAccount.transfer(amount: 100.0, to: checkingAccount)
    } catch let error as AccountOperationsError {
        print("Caught: \(error.localizedDescription)")
    } catch {
        print("Unexpected error: \(error.localizedDescription)")
    }
    
    
    
    
    let analytics = AccountAnalytics(transactions: checkingAccount.transactions)
    
    print(String(format: "Total Credits: $%.2f", analytics.totalCredits))
    print(String(format: "Total Debits: $%.2f", analytics.totalDebits))
    print(String(format: "Net Flow: $%.2f", analytics.netFlow))

    if let largest = analytics.largestTransaction {
        print(String(format: "Largest Transaction: %@ ($%.2f)", largest.description, largest.amount))
    } else {
        print("Largest Transaction: None")
    }

    print("Transactions by Category:")
    let grouped = analytics.transactionsByCategory()
    for (category, trans) in grouped {
        print("  \(category): \(trans.count) transaction(s)")
    }
    
    
    reportResults(checkingAccount.transactions,title: "Checking Transactions")
    reportResults([checkingAccount, savingsAccount], title: "All Accounts")
    
    var originalTransaction = checkingAccount.transactions[0]
    var copiedTransaction = originalTransaction
    copiedTransaction.description = "new description in copied transaction"
    
    print("------")
    print("original transaction: \(originalTransaction.description)")
    print("copied transaction: \(copiedTransaction.description)")
    
    
    let accountref = checkingAccount
    print("\n--- Reference Semantics ---")
    print("Balance before deposit via alias: \(accountref.formattedBalance)")
    
    try? accountref.deposit(amount:100)
    print("Deposit of 100 made to ref.")
    print("checkingAccount balance: \(checkingAccount.formattedBalance)")
    print("accountref balance:    \(accountref.formattedBalance)")
    print("Both reflect the change? \(checkingAccount.balance == accountref.balance)")
    

    
    
    
}
runlabDemo()
// ============================================================
// END OF LAB
// ============================================================
//
// SELF-ASSESSMENT CHECKLIST
// Before submitting, verify:
//   [ ] All five types compile without warnings
//   [ ] runlabDemo() runs to completion with no crashes
//   [ ] Each error case in 7C is handled and prints a clear message
//   [ ] Struct copy semantics are correctly demonstrated in 7F
//   [ ] Class reference semantics are correctly demonstrated in 7F
//   [ ] reportResults works for both Transaction and BankAccount
//   [ ] Analytics produce correct totals matching your transactions
// ============================================================

