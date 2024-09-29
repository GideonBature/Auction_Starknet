use starknet::ContractAddress;
// use array::ArrayTrait;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use super::IAuctionSafeDispatcher;
use super::IAuctionSafeDispatcherTrait;
use super::IAuctionDispatcher;
use super::IAuctionDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_register_item() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    let before_register = dispatcher.is_registered("strk");
    assert(before_register == false, 'Item should not be registered');

    dispatcher.register_item("strk");

    let after_register = dispatcher.is_registered("strk");
    assert(after_register == true, 'Item should be registered');
}

#[test]
fn test_register_item_with_empty_name() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    dispatcher.register_item("");

    let test = dispatcher.is_registered("");
    assert(test == false, 'Name cannot be empty');
}

#[test]
fn test_unregister_item() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    dispatcher.register_item("strk");

    let before_unregister = dispatcher.is_registered("strk");
    assert(before_unregister == true, 'Item should be registered');

    dispatcher.unregister_item("strk");

    let after_unregister = dispatcher.is_registered("strk");
    assert(after_unregister == false, 'Item should not be registered');
}

#[test]
fn test_bid() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    dispatcher.register_item("strk");
    dispatcher.bid("strk", 10);
    let bid_value = dispatcher.get_bid("strk");
    assert(bid_value == 10, 'Bid should be 10');
}

#[test]
fn test_bid_with_zero_value() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    dispatcher.register_item("strk");
    dispatcher.bid("strk", 0);
    let bid_value = dispatcher.get_bid("strk");
    assert(bid_value != 0, 'Bid cannot be 0');
}

#[test]
fn test_bid_with_negative_value() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    dispatcher.register_item("strk");
    dispatcher.bid("strk", -15);
    let bid_value = dispatcher.get_bid("strk");
    assert(bid_value > 0, 'Bid cannot be a negative value');
}

#[test]
fn test_get_highest_bidder() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    dispatcher.register_item("strk");
    dispatcher.bid("strk", 15);

    dispatcher.register_item("btc")
    dispatcher.bid("btc", 200);

    dispatcher.register_item("eth")
    dispatcher.bid("eth", 50);

    let bid_value_strk = dispatcher.get_highest_bidder("strk");
    let bid_value_btc = dispatcher.get_highest_bidder("btc");
    let bid_value_eth = dispatcher.get_highest_bidder("eth");

    assert(bid_value_strk != bid_value_btc, 'Bid should be 200');
    assert(bid_value_eth != bid_value_btc, 'Bid should be 200');
}

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }
