import pytest
from brownie.network.state import Chain

LOCK_TIME = 10

@pytest.fixture
def bloodoath_instance(BloodOath, accounts):
    yield BloodOath.deploy([accounts[0], accounts[1]], LOCK_TIME, {'from': accounts[0]})

def test_initial_state_takers(bloodoath_instance, accounts):
    """Test if contract initial state was set for given oath takers.
    """
    assert bloodoath_instance.takers(0) == accounts[0].address, "First taker not correctly set."
    assert bloodoath_instance.takers(1) == accounts[1].address, "First taker not correctly set."

def test_initial_state_takers(bloodoath_instance, accounts):
    """Test if contract initial state was set for given oath takers.
    """
    assert bloodoath_instance.takers(0) == accounts[0].address, "First taker not correctly set."
    assert bloodoath_instance.takers(1) == accounts[1].address, "First taker not correctly set."

def test_initial_state_lockEnd(bloodoath_instance):
    """Test if correct lock end was set during initialization.
    """
    chain = Chain()
    assert bloodoath_instance.lockEnd() == chain.time() + LOCK_TIME + 1
