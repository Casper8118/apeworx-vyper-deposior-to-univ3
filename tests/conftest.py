import pytest

@pytest.fixture
def owner(accounts):
    return accounts["0xb27fa340eb99bad3d55ea4bf255f64cc9693f6c6"]

@pytest.fixture
def depositor(accounts, project, owner):
    contract = owner.deploy(project.Depositor)
    return contract
