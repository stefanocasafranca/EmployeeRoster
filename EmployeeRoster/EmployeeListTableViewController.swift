import UIKit

// Step 1: Controller for displaying the list of employees. Also inherits all the protocol down here
class EmployeeListTableViewController: UITableViewController, EmployeeDetailTableViewControllerDelegate {

    // Step 2: Data source – list of employees projected as an Array inside the var employees
    var employees: [Employee] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Best Practice: Setup UI here (if needed)
    }

    // MARK: - Table View Data Source

    // Step 3: Number of rows = number of employees. Returns the Array nummber
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }

    
    // Step 4: Build each row in the list to show an employee
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Step 4.1: Get a recycled cell (faster than making a new one)
        let cellForEmployee = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath)
        
        // Step 4.2: Get the employee for this row from the list
        let employee = employees[indexPath.row]

        // Step 4.3: Create a layout to hold text (name + job type)
        var content = cellForEmployee.defaultContentConfiguration()
        
        // Step 4.4: Set the name and job type to show in the cell
        content.text = employee.name
        content.secondaryText = employee.employeeType.description
        
        // Step 4.5: Apply that layout to the cell (makes it show up)
        cellForEmployee.contentConfiguration = content

        // Step 4.6: Return the ready-to-show cell to the table
        return cellForEmployee
    }
    

    // Step 5: Enable swipe-to-delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            employees.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation
    // Step 6: Navigate to the Employee Detail screen (EmployeeDetailTableViewController.swift)
    @IBSegueAction func showEmployeeDetail(_ coder: NSCoder, sender: Any?) -> EmployeeDetailTableViewController? {
        
        // Step 6.0: Create an instance of the detail view controller using the storyboard
        let detailViewController = EmployeeDetailTableViewController(coder: coder)
        
        // Step 6.0.1: Set this current screen as the delegate to receive data back
        detailViewController?.delegate = self

        // Step 6.1: If an existing row was tapped, find out which one
        guard
            let cell = sender as? UITableViewCell,              // Make sure the sender is a table cell
            let indexPath = tableView.indexPath(for: cell)      // Get the index path of that cell
        else {
            // Step 6.1.1: If no cell was tapped (e.g., "Add" button), return the empty form
            return detailViewController
        }

        // Step 6.2: Get the tapped employee and send it to the detail screen
        let employee = employees[indexPath.row]
        detailViewController?.employee = employee

        // Step 6.3: Return the fully configured detail screen
        return detailViewController
    }

    // Step 7: Called when returning from detail view
    @IBAction func unwindToEmployeeList(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - EmployeeDetailTableViewControllerDelegate
    // Step 8: Handle saving employee from detail view
    func employeeDetailTableViewController(_ controller: EmployeeDetailTableViewController, didSave employee: Employee) {
        
        // 📍 If a row is selected, we're editing an existing employee
        //Logic: Call the protocol only...
        if let indexPath = tableView.indexPathForSelectedRow {
        
        // Edit existing employee
            // Remove the old employee at that row
            employees.remove(at: indexPath.row)
            // Insert the updated employee back in the same place
            employees.insert(employee, at: indexPath.row)
        } else {
            // No row selected = we're adding a new employee
            employees.append(employee)
        }
        //Refresh
        tableView.reloadData()
        //Close the detailed screen
        dismiss(animated: true, completion: nil)
    }
}
