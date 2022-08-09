from ape import networks, accounts, project, reverts
from ape.logging import logger
    
def test_deploy_deposit(owner, depositor):
    depositor.deposit(1, 100, value="10 eth")

    with reverts("Parameter length is not match"):
        depositor.deposit()
    
    with reverts("No value"):
        depositor.deposit(1, 100)