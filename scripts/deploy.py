from ape import networks, accounts, project
with networks.ethereum.mainnet.use_provider("infura"):

    def main():
        account = accounts.load("default")
        print(account.balance())
        contract = account.deploy(project.Depositor)
        contract.viewThis()