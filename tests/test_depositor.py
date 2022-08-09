from ape import networks, accounts, project, reverts
from ape.logging import logger
    
def test_deploy_deposit(owner, depositor):    
    print(owner.balance)
    with reverts("value can't be zero"):
        depositor.deposit(1, 100, sender=owner)
        
    receipt = depositor.deposit(1, 100, value="10000000000 gwei", sender=owner)
    
    for log in depositor.Swap.from_receipt(receipt):
        print(log, log.depositor, log.amount)
    
    for log in depositor.TokenApproved.from_receipt(receipt):
        print(log, log.target, log.amount0, log.amount1)

    assert 1 == 2