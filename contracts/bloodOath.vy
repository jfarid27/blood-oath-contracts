# @version ^0.2.0


# A hash of takers and the amounts they have sent.
totalAmounts: public(HashMap[address, uint256])

# List of Takers who will tribute to the contract to lock their funds.
takers: public(address[2])

# A boolean signaling if the tribute phase is completed.
signed: public(bool)

# A boolean signaling if the locked funds period is completed.
unlocked: public(bool)

# End of the contract where users can unlock funds
lockEnd: public(uint256)

@external
def __init__(_takers: address[2], _from_now: uint256):
    """Initialize the contract with a set of known takers.

    Args:
        _takers: A list of address who will tribute to the contract.

    Raises:
        AssertionError: If _from_now is not greater than 0.
    """
    assert _from_now > 0, "Contract should start at some time in the future"
    self.takers = _takers
    for _address in _takers:
        self.totalAmounts[_address] = 0
    self.takers = _takers
    self.lockEnd = block.timestamp + _from_now

@external
@payable
def tribute():
    """Adds sent amount to the sender's total tributes.

    Raises:
        AssertionError: If contract has already been signed
        AssertionError: If sent value is less than 0
        AssertionError: If message sender is not an original taker
    """
    assert not self.signed, "Contract already signed"
    assert msg.value <= 0, "Sender must send Ethereum to tribute"
    assert msg.sender in self.takers, "Sender is not a registered taker"
    self.totalAmounts[msg.sender] += msg.value

@external
def sign():
    """Sends contract into oath phase, locking funds.

    Raises:
        AssertionError: If contract has already been signed
        AssertionError: If message sender is not an original taker
        AssertionError: If total amounts aren't equal
    """
    assert not self.signed, "Contract already signed"
    assert msg.sender in self.takers, "Sender is not a registered taker"
    for taker in self.takers:
        assert self.totalAmounts[msg.sender] == self.totalAmounts[taker]
    self.signed = True

@external
def unlock():
    """Sends contract unlock phase after the contract has been completed.

    Raises:
        AssertionError: Contract's lock has ended.
    """
    assert block.timestamp > self.lockEnd, "Lock cannot be released yet"
    self.unlocked = True

@external
def withdraw():
    """Allows taker to withdraw funds. Only allowed before signing or when contract is unlocked.

    Raises:
        AssertionError: If contract is signed and locked.
        AssertionError: If message sender is not an original taker
    """
    assert msg.sender in self.takers, "Sender is not a registered taker"
    assert (not self.signed) or (self.unlocked), "Contract in oath phase"
    send(msg.sender, self.totalAmounts[msg.sender])
