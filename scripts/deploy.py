from ape import project, accounts, chain, config, networks
from scripts.helper_functions import get_account


def deploy():
    account = get_account()
    depositor = project.Depositor.deploy(
        sender = account
    )
    print(f"Depositor deployed to {depositor.address}")
    return depositor


def main():
    deploy_keepers_consumer()
