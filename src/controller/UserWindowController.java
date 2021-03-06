package controller;
import javafx.beans.property.SimpleStringProperty;
import javafx.beans.property.StringProperty;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.stage.Stage;
import model.YourSQLBank;
import java.sql.ResultSet;
import java.util.List;

public class UserWindowController {
    @FXML private VBox mainWindow = new VBox();
    @FXML private GridPane userTableHeader = new GridPane();
    @FXML private Button depositCheckingButton = new Button();
    @FXML private Button depositSavingButton = new Button();
    @FXML private Button withdrawCheckingButton = new Button();
    @FXML private Button withdrawSavingButton = new Button();
    @FXML private Button closeAccountButton = new Button();
    @FXML private TextField transactionAmount = new TextField();
    @FXML private StringProperty userName;
    @FXML private StringProperty checkingAccountBalance;
    @FXML private StringProperty savingAccountBalance;
    @FXML private StringProperty transactionHistory;

    String loggedInUsername = LoginLogoutController.username_;
    YourSQLBank db = LoginLogoutController.db;

    public UserWindowController() {
        userName = new SimpleStringProperty();
        checkingAccountBalance = new SimpleStringProperty();
        savingAccountBalance = new SimpleStringProperty();
        transactionHistory = new SimpleStringProperty();
        updateGui();
    }

    public void updateGui() {
        String[] data = db.getInfo(loggedInUsername);
        boolean accountOpen = true;
        if(data[4].contains("0")) {
            accountOpen = false;
            System.out.println("Your account is closed. You cannot make any transactions.");
        }
        setUserName(data[1]+" "+data[2]+" | Your account is now "+(accountOpen? "open." : "closed."));
        setcheckingAccountBalance(data[5]);
        setSavingAccountBalance(data[6]);
        setTransactionHistory("\n\tTRSN_ID\tACC_ID\tACC_TYPE\tTRSN_TYPE\tTRSN_AMT\n"+YourSQLBank.printS(db.getUserTransactionHistoryTable(loggedInUsername)));
        depositCheckingButton.setDisable(!accountOpen);
        depositSavingButton.setDisable(!accountOpen);
        withdrawCheckingButton.setDisable(!accountOpen);
        withdrawSavingButton.setDisable(!accountOpen);
        closeAccountButton.setDisable(!accountOpen);
        transactionAmount.setDisable(!accountOpen);
    }

    public String getUserName() {
        return userName.get();
    }

    public StringProperty userNameProperty() {
        return userName;
    }

    public void setUserName(String user_name) {
        userName.set(user_name);
    }

    public String getTransactionHistory() {
        return transactionHistory.get();
    }

    public StringProperty transactionHistoryProperty() {
        return transactionHistory;
    }

    public void setTransactionHistory(String transaction_history) {
        transactionHistory.set(transaction_history);
    }

    public String getCheckingAccountBalance() {
        return checkingAccountBalance.get();
    }

    public StringProperty checkingAccountBalanceProperty() {
        return checkingAccountBalance;
    }

    public void setcheckingAccountBalance(String checkingAccount_Balance) {
        checkingAccountBalance.set(checkingAccount_Balance);
    }

    public String getSavingAccountBalance() {
        return savingAccountBalance.get();
    }

    public StringProperty savingAccountBalanceProperty() {
        return savingAccountBalance;
    }

    public void setSavingAccountBalance(String savingAccount_Balance) {
        savingAccountBalance.set(savingAccount_Balance);
    }

    public static double formattedAmount(String amount, ActionEvent e) throws Exception {
        double amt;
        try {
            amt = Double.parseDouble(amount);
            if(amt < 0)
                throw new NumberFormatException();
        } catch(NumberFormatException ex) {
            LoginLogoutController.displayAlert(e, "Invalid Number Entered", "Please try a proper positive numeric entry.", "Please Try Again.");
            throw new Exception();
        }
        return amt;
    }

    public static double formattedAmount(TextField amount, ActionEvent e) throws Exception {
        String num = amount.getText();
        amount.clear();
        return formattedAmount(num, e);
    }

    public void depositMoneyInChecking(ActionEvent actionEvent) throws Exception {
        createTransaction("DPST", formattedAmount(this.transactionAmount, actionEvent), "CHKG", actionEvent);
    }

    public void depositMoneyInSaving(ActionEvent actionEvent) throws Exception {
        createTransaction("DPST", formattedAmount(this.transactionAmount, actionEvent), "SVNG", actionEvent);
    }

    public void withdrawFromChecking(ActionEvent actionEvent) throws Exception {
        createTransaction("WTDW", formattedAmount(this.transactionAmount, actionEvent), "CHKG", actionEvent);
    }

    public void withdrawFromSaving(ActionEvent actionEvent) throws Exception {
        createTransaction("WTDW", formattedAmount(this.transactionAmount, actionEvent), "SVNG", actionEvent);
    }

    public void createTransaction(String transaction_type, double amount, String account_type, ActionEvent e) {
        transactionAmount.clear();
        String[] data = db.getInfo(loggedInUsername);
        if(data[4].contains("1") && safeTransaction(transaction_type, amount, account_type, data, e))
            db.AddTransaction(loggedInUsername, transaction_type, amount, account_type);
        updateGui();
    }

    public boolean safeTransaction(String transaction_type, double amount, String account_type, String[] data, ActionEvent e) {
        if(transaction_type.equals("WTDW") && amount > ((account_type.equals("CHKG"))? Double.parseDouble(data[5]) : Double.parseDouble(data[6]))) {
            LoginLogoutController.displayAlert(e, "Not Enough Money", "There isn't enough money in your account to withdraw $"+amount+".", "You cannot withdraw from account if you don't have the money.\n\nPlease Try Again.");
            System.out.println("You cannot withdraw from account if you don't have the money...\n");
            return false;
        }
        return true;
    }

    public void closeAccount(ActionEvent actionEvent) {
        db.closeAccount(loggedInUsername);
        updateGui();
    }

    public void showLogOutUserWindow(ActionEvent actionEvent) throws Exception {
        Parent logoutPageParent = FXMLLoader.load(getClass().getResource("/fxml/goodbye.fxml"));
        Scene logoutPageScene = new Scene(logoutPageParent, 1000, 500);
        Stage logOutStage = (Stage) ((Node) actionEvent.getSource()).getScene().getWindow();
        logOutStage.setScene(logoutPageScene);
        logOutStage.show();
        Thread.sleep(2000);
        System.exit(0);
    }
}

