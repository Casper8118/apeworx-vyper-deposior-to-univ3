from ape import networks, accounts, project
from ape.logging import logger

def main():
    logger.info("This is a log message, {}", accounts)
    account = accounts.load("default")
    print(account.balance)
    contract = account.deploy(project.Depositor)
    contract.viewThis()