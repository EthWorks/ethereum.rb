import "contracts/AccountingLib.sol";

contract TestAccounting {
        AccountingLib.Bank bank;
        /*
         *  Account Management API
         */
        function getAccountBalance(address accountAddress) constant public returns (uint) {
                return bank.accountBalances[accountAddress];
        }

        function deposit() public {
                deposit(msg.sender);
        }

        function deposit(address accountAddress) public {
                /*
                 *  Public API for depositing funds in a specified account.
                 */
                AccountingLib.deposit(bank, accountAddress, msg.value);
                AccountingLib.Deposit(msg.sender, accountAddress, msg.value);
        }

        function addFunds(uint value) public {
                addFunds(msg.sender, value);
        }

        function addFunds(address accountAddress, uint value) public {
                AccountingLib.addFunds(bank, accountAddress, value);
        }

        function withdraw(uint value) public {
                /*
                 *  Public API for withdrawing funds.
                 */
                if (AccountingLib.withdraw(bank, msg.sender, value)) {
                        AccountingLib.Withdrawal(msg.sender, value);
                }
                else {
                        AccountingLib.InsufficientFunds(msg.sender, value, bank.accountBalances[msg.sender]);
                }
        }

        function deductFunds(uint value) public {
                deductFunds(msg.sender, value);
        }

        function deductFunds(address accountAddress, uint value) public {
                AccountingLib.deductFunds(bank, accountAddress, value);
        }

        function setAccountBalance(uint value) public {
                setAccountBalance(msg.sender, value);
        }

        function setAccountBalance(address accountAddress, uint value) public {
                bank.accountBalances[accountAddress] = value;
        }
}
