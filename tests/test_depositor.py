from ape import networks, accounts, project, reverts
from ape.logging import logger
    
def test_deploy_deposit(owner, depositor):    
    logger.info(owner.balance)
    with reverts("value can't be zero"):
        depositor.deposit(1, 100, sender=owner)
        
    depositor.deposit(1, 100, value="10 eth", sender=owner)