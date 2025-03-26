import UIKit


/*
User interacts with the View (e.g. Main.storyboard)
↓
Controller handles the action (e.g. UITableViewController)
↓
Controller updates the Model (e.g. Employee.swift)
↓
Model data is changed or saved
↓
Controller updates the View with new data
*/


// Step 1: Protocol to send saved employee data back (↩ Step 8 in EmployeeListTableViewController.swift)
protocol EmployeeDetailTableViewControllerDelegate: AnyObject {
    func employeeDetailTableViewController(_ controller: EmployeeDetailTableViewController, didSave employee: Employee)
}

//Step 2:
// This class is the Controller in MVC.
// It manages the screen (View) for adding/editing an employee.
// It connects user input with the Employee data (Model).
class EmployeeDetailTableViewController: UITableViewController, EmployeeTypeTableViewControllerDelegate {
    
    // Step 3: UI connections
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var dobLabel: UILabel!
    @IBOutlet var employeeTypeLabel: UILabel!
    @IBOutlet var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet var dobDatePicker: UIDatePicker!
    
    // Step 4: Variables to track data and delegate
    weak var delegate: EmployeeDetailTableViewControllerDelegate?
    var employee: Employee?
    var employeeType: EmployeeType?
    
    // Step 5: Control whether to show/hide the date picker
    var isEditingBirthday: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView() // Function is right here ↓ Step 6
        updateSaveButtonState() // Function is right here ↓↓ Step 7
    }
    
    // Step 6: Fill view with employee data if editing
    func updateView() {
        if let employee = employee {
            navigationItem.title = employee.name
            nameTextField.text = employee.name
            dobLabel.text = employee.dateOfBirth.formatted(date: .abbreviated, time: .omitted)
            dobLabel.textColor = .label
            employeeTypeLabel.text = employee.employeeType.description
            employeeTypeLabel.textColor = .label
        } else {
            navigationItem.title = "New Employee"
            prepareDOBPicker()
        }
    }
    
    // Step 7: Enable save only when fields are valid
    private func updateSaveButtonState() {
        let shouldEnableSaveButton = nameTextField.text?.isEmpty == false && employeeType != nil
        saveBarButtonItem.isEnabled = shouldEnableSaveButton
    }
    
    // Step 8: Save button logic
    @IBAction func saveButtonTapped(_ sender: Any) {
        //Make sure the data (name and employee type) is filled before saving
        guard let name = nameTextField.text, let employeeType = employeeType else { return }
        //Uses the Blueprint from the swift file: Employee (Model) using data from the form (View)
        // This uses the struct defined in the Employee.swift file
        let employee = Employee(name: name, dateOfBirth: dobDatePicker.date, employeeType: employeeType)
        // Send the employee back to the list screen using the delegate (Controller → Controller communication)
        delegate?.employeeDetailTableViewController(self, didSave: employee)
        //Extra: “If delegate is set (not nil), then call this method.”
        //What is the delegate? It’s a reference to another View Controller — in this case: E.ListTVC
    }
    
    // Step 9: Cancel button clears employee
    @IBAction func cancelButtonTapped(_ sender: Any) {
        employee = nil // Nil makes it return? A: No, remember this is the Controller, not the
    }
    
    // Step 10: Monitor name changes to validate save
    @IBAction func nameTextFieldDidChange(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // Step 11: Update label when date picker changes
    @IBAction func dobPickerValueChanged(_ sender: Any) {
        dobLabel.text = dobDatePicker.date.formatted(date: .abbreviated, time: .omitted)
    }
    
    // Step 12: Navigate to select employee type (↳ Step 1 in EmployeeTypeTableViewController.swift)
    @IBSegueAction func showEmployeeTypes(_ coder: NSCoder) -> EmployeeTypeTableViewController? {
        let typeController = EmployeeTypeTableViewController(coder: coder)
        typeController?.delegate = self
        return typeController
    }
    
    // Step 13: Show/hide date picker cell dynamically
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 2, section: 0) && isEditingBirthday == false {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    // Step 14: Toggle date picker when DOB cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath(row: 1, section: 0) {
            isEditingBirthday.toggle()
            dobLabel.textColor = .label
            dobLabel.text = dobDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    // MARK: - EmployeeTypeTableViewControllerDelegate
    
    // Step 15: Handle employee type selection from the type picker screen
    func employeeTypeTableViewController(_ controller: EmployeeTypeTableViewController, didSelect employeeType: EmployeeType) {
        // Save the selected employee type to this screen's local variable
        self.employeeType = employeeType
        // Change the label's color back to normal (system default) — in case it was gray before
        employeeTypeLabel.textColor = .label
        // Update the label to show the selected type (e.g., "Part Time", "Exempt Full Time")
        employeeTypeLabel.text = employeeType.description
        
        // ✅ Enable or disable the Save button depending on whether all required fields are filled
        updateSaveButtonState()
    }
    
    
    // Step 16: Pre-fill date picker to sensible middle-age default
    private func prepareDOBPicker() {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.calendar = Calendar.current
        guard let currentYear = dateComponents.year else { return }
        dateComponents.month = 6
        dateComponents.day = 15
        dateComponents.year = (currentYear - 40)
        dobDatePicker.date = dateComponents.date ?? Date()
    }
    
}
