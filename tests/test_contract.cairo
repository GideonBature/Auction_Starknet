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

    let before_register = dispatcher.is_registered("hello");
    assert(before_register == false, 'Item should not be registered');

    dispatcher.register_item("hello");

    let after_register = dispatcher.is_registered("hello");
    assert(after_register == true, 'Item should be registered');
}

#[test]
fn test_register_item_with_empty_name() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    let register = dispatcher.register_item("");

    let test = dispatcher.is_registered("");
    assert(test == false, 'Name cannot be empty');
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
