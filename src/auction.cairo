#[starknet::interface]
trait IAuction<T> {
    fn register_item(ref self: T, item_name: ByteArray);
    fn unregister_item(ref self: T, item_name: ByteArray);
    fn bid(ref self: T, item_name: ByteArray, amount: u32);
    fn get_highest_bidder(self: @T, item_name: ByteArray) -> u32;
    fn is_registered(self: @T, item_name: ByteArray) -> bool;
}


#[starknet::contract]
pub mod Auction {
    use super::IAuction;
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map, StorageMapWriteAccess, StorageMapReadAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess, Vec, VecTrait, MutableVecTrait
    };

    #[storage]
    struct Storage {
        bid: Map::<ByteArray, u32>,
        register: Map::<ByteArray, bool>,
        allBids: Vec::<u32>,
        owner: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ItemRegistered: ItemRegistered,
        ItemUnregistered: ItemUnregistered,
        ItemBid: ItemBid,
    }

    #[derive(Drop, starknet::Event)]
    struct ItemRegistered {
        item_name: ByteArray,
    }

    #[derive(Drop, starknet::Event)]
    struct ItemUnregistered {
        item_name: ByteArray,
    }

    #[derive(Drop, starknet::Event)]
    struct ItemBid {
        item_name: ByteArray,
        amount: u32,
    }
    //TODO Implement interface and events .. deploy contract
    #[constructor]
    fn constructor(ref self: ContractState, owner: felt252) {
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl AuctionImpl of IAuction<ContractState> {
        fn register_item(ref self: ContractState, item_name: ByteArray) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner can register items');
            assert(item_name == "", 'Item name cannot be empty');

            self.register.write(item_name, true);

            self.emit(ItemRegistered { item_name });
        }

        fn unregister_item(ref self: ContractState, item_name: ByteArray) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner can unregister items');

            self.register.write(item_name, false);

            self.emit(ItemUnregistered { item_name });
        }

        fn bid(ref self: ContractState, item_name: ByteArray, amount: u32) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller != owner, 'Only users can bid');
            assert(amount <= 0, 'Amount must be greater than 0');

            let register = self.register.read(item_name);
            assert(register, 'Item is not registered');

            self.bid.write(item_name, amount);
            self.allBids.write(amount);

            self.emit(ItemBid { item_name, amount });
        }

        fn get_highest_bidder(self: @ContractState, item_name: ByteArray) -> u32 {
            let caller = get_caller_address();
            let owner = self.owner.read();

            assert(caller == owner, 'Only owner can get highest bidder');

            let mut highest_bid = 0;
            let len = allBids.len();

            for i in 0..len {
                if allBids[i] > highest_bid {
                    highest_bid = allBids[i];
                }
            }

            highest_bid
        }

        fn is_registered(self: @ContractState, item_name: ByteArray) -> bool {
            let caller = get_caller_address();
            let owner = self.owner.read();

            assert(caller == owner, 'Only owner can check if item is registered');

            let register = self.register.read(item_name);
            register
        }
    }
}
