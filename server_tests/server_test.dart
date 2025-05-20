import 'package:divvy/models/chore.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/models/user.dart';
import 'package:divvy/util/server_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// This code is not in the test/ directory in order to prevent
/// it from being run when the CI is triggered. This code will not
/// succeed without the server running, which the CI pipeline does not
/// do.

void main() {
  group('User collection tests', () {
    test('User doc is properly added & deleted', () async {
      // Create a generic user
      final userID = '8590480294134';
      final email = 'test@test.edu';
      await createUser(userID, email);
      final receivedUser = await fetchUser(userID);
      assert(receivedUser != null);
      // Assert data is correct
      expect(receivedUser!.email, email);
      expect(receivedUser.houseID, '');
      // Clean up - delete data
      await deleteUser(userID);
      final deletedUserData = await fetchUser(userID);
      assert(deletedUserData == null);
    });
  });

  group('House tests', () {
    test('House can be added to the db', () async {
      // Create a generic user
      final userID = '9028490320973';
      final email = 'test@test.edu';
      await createUser(userID, email);
      DivvyUser? receivedUser = await fetchUser(userID);
      assert(receivedUser != null);
      // Assert data is correct
      expect(receivedUser!.email, email);
      expect(receivedUser.houseID, '');

      // add the house
      final newHouse = House.fromNew(
        houseName: 'Test house!!',
        uid: receivedUser.id,
        joinCode: '86940jkf32',
      );
      await createHouse(receivedUser, newHouse, 'name');
      // make sure user had their doc updated
      receivedUser = await fetchUser(userID);
      assert(receivedUser != null);
      assert(receivedUser!.houseID != '');
      final receivedHouse = await fetchHouse(receivedUser!.houseID);
      assert(receivedHouse != null);
      expect(receivedHouse!.id, newHouse.id);
      expect(receivedHouse.joinCode, newHouse.joinCode);
      expect(receivedHouse.name, newHouse.name);

      // Clean up - delete data
      await deleteUser(userID);
      await deleteHouse(receivedHouse.id);
      final deletedUserData = await fetchUser(userID);
      assert(deletedUserData == null);
      final deletedHouseData = await fetchHouse(receivedHouse.id);
      assert(deletedHouseData == null);
    });

    test('House data can be edited', () async {
      // Create a generic user
      final userID = '9028490320973';
      final email = 'test@test.edu';
      await createUser(userID, email);
      DivvyUser? receivedUser = await fetchUser(userID);
      assert(receivedUser != null);
      // Assert data is correct
      expect(receivedUser!.email, email);
      expect(receivedUser.houseID, '');

      // add the house
      final newHouse = House.fromNew(
        houseName: 'Test house!!',
        uid: receivedUser.id,
        joinCode: '86940jkf32',
      );
      await createHouse(receivedUser, newHouse, 'name');
      // make sure user had their doc updated
      receivedUser = await fetchUser(userID);
      assert(receivedUser != null);
      assert(receivedUser!.houseID != '');
      House? receivedHouse = await fetchHouse(receivedUser!.houseID);
      assert(receivedHouse != null);
      expect(receivedHouse!.id, newHouse.id);
      expect(receivedHouse.joinCode, newHouse.joinCode);
      expect(receivedHouse.name, newHouse.name);

      // edit hosue name
      newHouse.name = 'edited';
      await upsertHouse(newHouse);
      receivedHouse = await fetchHouse(newHouse.id);
      assert(receivedHouse != null);
      expect(receivedHouse!.id, newHouse.id);
      expect(receivedHouse.joinCode, newHouse.joinCode);
      expect(receivedHouse.name, 'edited');

      // Clean up - delete data
      await deleteUser(userID);
      await deleteHouse(receivedHouse.id);
      final deletedUserData = await fetchUser(userID);
      assert(deletedUserData == null);
      final deletedHouseData = await fetchHouse(receivedHouse.id);
      assert(deletedHouseData == null);
    });
  });

  group('Member tests', () {
    test('Member docs can be updated when a user joins', () async {
      // Create a generic user to start house
      final userID = '908590209432';
      final email = 'founder@test.edu';
      await createUser(userID, email);
      final receivedUser = await fetchUser(userID);
      assert(receivedUser != null);

      // add a house to the db
      final newHouse = House.fromNew(
        houseName: 'Test house!!',
        uid: receivedUser!.id,
        joinCode: '86940jkf32',
      );
      await createHouse(receivedUser, newHouse, 'name');
      House? receivedHouse = await fetchHouse(receivedUser.houseID);
      assert(receivedHouse != null);

      // now add another user to the house
      final userID2 = '9090ujf0u302432';
      final email2 = 'member2@test.edu';
      await createUser(userID2, email2);
      final receivedUser2 = await fetchUser(userID2);
      assert(receivedUser2 != null);
      await addUserToHouse(receivedUser2!, receivedHouse!.joinCode, 'name');
      // Assert user was added to house fully
      expect(receivedUser2.houseID, receivedHouse.id);
      receivedHouse = await fetchHouse(receivedUser2.houseID);
      assert(receivedHouse != null);
      final members = await fetchMembers(receivedHouse!.id);
      assert(members != null);
      // check that both user and creator have member docs
      assert(members![userID] != null);
      assert(members![userID2] != null);

      // Clean up - delete data
      await deleteUser(userID);
      await deleteUser(userID2);
      await deleteHouse(receivedHouse.id);
    });

    test('Member docs can be edited & deleted', () async {
      // Create three users
      final member1ID = '549038t09g09r342';
      final member2ID = 'fieowtu48935u230';
      final member3ID = '39120ujrfioj9032';
      List<Future> futures = [
        createUser(member1ID, 'member1@test.com'),
        createUser(member2ID, 'member1@test.com'),
        createUser(member3ID, 'member1@test.com'),
      ];
      await Future.wait(futures);
      final founder = await fetchUser(member1ID);
      final mem2 = await fetchUser(member2ID);
      final mem3 = await fetchUser(member3ID);
      assert(founder != null);
      assert(mem2 != null);
      assert(mem3 != null);

      // add a house to the db
      final house = House.fromNew(
        houseName: 'Test house!!',
        uid: founder!.id,
        joinCode: '12y3893uroi2',
      );
      await createHouse(founder, house, 'name');

      // add users to house
      futures = [
        addUserToHouse(mem2!, house.joinCode, 'name'),
        addUserToHouse(mem3!, house.joinCode, 'name'),
      ];
      await Future.wait(futures);

      // make sure member docs exist
      Map<MemberID, Member>? members = await fetchMembers(house.id);
      assert(members != null);
      expect(members!.length, 3);
      assert(members[member1ID] != null);
      assert(members[member2ID] != null);
      assert(members[member3ID] != null);

      // now edit a member doc
      final updatedMember = members[member3ID];
      updatedMember!.name = 'edited';
      await upsertMember(updatedMember, house.id);
      members = await fetchMembers(house.id);
      assert(members != null);
      expect(members!.length, 3);
      assert(members[member1ID] != null);
      assert(members[member2ID] != null);
      assert(members[member3ID] != null);
      expect(members[member3ID]!.name, 'edited');

      // now delete member3
      await deleteMember(memberID: member3ID, houseID: house.id);
      members = await fetchMembers(house.id);
      assert(members != null);
      expect(members!.length, 2);
      assert(members[member1ID] != null);
      assert(members[member2ID] != null);
      assert(members[member3ID] == null);

      // Clean up - delete data
      futures = [
        deleteUser(member1ID),
        deleteUser(member2ID),
        deleteUser(member3ID),
        deleteHouse(house.id),
      ];
      await Future.wait(futures);
      // Make sure all subgroups were deleted
      final deletedChores = await fetchChores(house.id);
      assert(deletedChores == null || deletedChores.isEmpty);
    });
  });

  group('Subgroup tests', () {
    test('Subgroup docs can be created & edited', () async {
      // Create three users
      final member1ID = '9508239408304';
      final member2ID = '0850948902432';
      final member3ID = 'fji2u59349032jgf';
      List<Future> futures = [
        createUser(member1ID, 'member1@test.com'),
        createUser(member2ID, 'member1@test.com'),
        createUser(member3ID, 'member1@test.com'),
      ];
      await Future.wait(futures);
      final founder = await fetchUser(member1ID);
      final mem2 = await fetchUser(member2ID);
      final mem3 = await fetchUser(member3ID);
      assert(founder != null);
      assert(mem2 != null);
      assert(mem3 != null);

      // add a house to the db
      final house = House.fromNew(
        houseName: 'Test house!!',
        uid: founder!.id,
        joinCode: '94320483090s',
      );
      await createHouse(founder, house, 'name');
      House? receivedHouse = await fetchHouse(house.id);
      assert(receivedHouse != null);

      // add users to house
      futures = [
        addUserToHouse(mem2!, receivedHouse!.joinCode, 'name'),
        addUserToHouse(mem3!, receivedHouse.joinCode, 'name'),
      ];
      await Future.wait(futures);

      // now create a subgroup!!
      final subgroup1 = Subgroup.fromNew(
        members: [member3ID, member2ID],
        name: '2 & 3',
        color: Colors.black,
      );
      final subgroup2 = Subgroup.fromNew(
        members: [member1ID, member2ID],
        name: '1 & 2',
        color: Colors.black,
      );
      futures = [
        upsertSubgroup(subgroup1, house.id),
        upsertSubgroup(subgroup2, house.id),
      ];
      await Future.wait(futures);
      // Now make sure data was properly created
      final subgroups = await fetchSubgroups(house.id);
      assert(subgroups != null);
      final sub1 = subgroups![subgroup1.id];
      assert(sub1 != null);
      final sub2 = subgroups[subgroup2.id];
      assert(sub2 != null);
      expect(sub1!.name, '2 & 3');
      expect(sub2!.name, '1 & 2');
      assert(sub1.members.length == 2);
      assert(sub2.members.length == 2);
      assert(setEquals(sub1.members.toSet(), {member2ID, member3ID}));
      assert(setEquals(sub2.members.toSet(), {member2ID, member1ID}));

      // make sure subgroup data can be edited
      sub1.name = 'edited';
      await upsertSubgroup(sub1, house.id);
      final editedSub = await fetchSubgroup(sub1.id, house.id);
      assert(editedSub != null);
      expect(editedSub!.name, 'edited');

      // Clean up - delete data
      futures = [
        deleteUser(member1ID),
        deleteUser(member2ID),
        deleteUser(member3ID),
        deleteHouse(house.id),
      ];
      await Future.wait(futures);
      // Make sure all subgroups were deleted
      final deletedSubs = await fetchSubgroups(house.id);
      assert(deletedSubs == null || deletedSubs.isEmpty);
    });
    test('Subgroup docs can be deleted', () async {
      // Create three users
      final member1ID = '9508239408304';
      final member2ID = '0850948902432';
      final member3ID = 'fji2u59349032jgf';
      List<Future> futures = [
        createUser(member1ID, 'member1@test.com'),
        createUser(member2ID, 'member1@test.com'),
        createUser(member3ID, 'member1@test.com'),
      ];
      await Future.wait(futures);
      final founder = await fetchUser(member1ID);
      final mem2 = await fetchUser(member2ID);
      final mem3 = await fetchUser(member3ID);
      assert(founder != null);
      assert(mem2 != null);
      assert(mem3 != null);

      // add a house to the db
      final house = House.fromNew(
        houseName: 'Test house!!',
        uid: founder!.id,
        joinCode: '94320483090s',
      );
      await createHouse(founder, house, 'name');

      // add users to house
      futures = [
        addUserToHouse(mem2!, house.joinCode, 'name'),
        addUserToHouse(mem3!, house.joinCode, 'name'),
      ];
      await Future.wait(futures);

      // now create a subgroup!!
      final subgroup1 = Subgroup.fromNew(
        members: [member3ID, member2ID],
        name: '2 & 3',
        color: Colors.black,
      );
      await upsertSubgroup(subgroup1, house.id);

      // Now make sure data was properly created
      final subgroups = await fetchSubgroups(house.id);
      assert(subgroups != null);
      assert(subgroups![subgroup1.id] != null);

      // make sure subgroup data can be deleted
      await deleteSubgroup(subgroupID: subgroup1.id, houseID: house.id);
      final deletedSub = await fetchSubgroup(subgroup1.id, house.id);
      assert(deletedSub == null);

      // Clean up - delete data
      futures = [
        deleteUser(member1ID),
        deleteUser(member2ID),
        deleteUser(member3ID),
        deleteHouse(house.id),
      ];
      await Future.wait(futures);
      // Make sure all subgroups were deleted
      final deletedSubs = await fetchSubgroups(house.id);
      assert(deletedSubs == null || deletedSubs.isEmpty);
    });
  });

  group('Chore (super) tests', () {
    test('Super chore can be added for one member', () async {
      // Create three users
      final member1ID = '9508239408304';
      final member2ID = '0850948902432';
      final member3ID = 'fji2u59349032jgf';
      List<Future> futures = [
        createUser(member1ID, 'member1@test.com'),
        createUser(member2ID, 'member1@test.com'),
        createUser(member3ID, 'member1@test.com'),
      ];
      await Future.wait(futures);
      final founder = await fetchUser(member1ID);
      final mem2 = await fetchUser(member2ID);
      final mem3 = await fetchUser(member3ID);
      assert(founder != null);
      assert(mem2 != null);
      assert(mem3 != null);

      // add a house to the db
      final house = House.fromNew(
        houseName: 'Test house!!',
        uid: founder!.id,
        joinCode: '94320483090s',
      );
      await createHouse(founder, house, 'name');
      House? receivedHouse = await fetchHouse(house.id);
      assert(receivedHouse != null);

      // add users to house
      futures = [
        addUserToHouse(mem2!, receivedHouse!.joinCode, 'name'),
        addUserToHouse(mem3!, receivedHouse.joinCode, 'name'),
      ];
      await Future.wait(futures);

      // now create a chore!!
      final chore = Chore.fromNew(
        name: 'Bathroom',
        pattern: Frequency.daily,
        daysOfWeek: [],
        assignees: [member1ID],
        emoji: '🚽',
        description: 'Clean bathroom',
        startDate: DateTime.now(),
      );
      await upsertChore(chore, house.id);

      // Now make sure data was properly created
      final dbChores = await fetchChores(house.id);
      assert(dbChores != null);
      expect(dbChores!.length, 1);
      final receivedChore = dbChores[chore.id];
      assert(receivedChore != null);
      expect(receivedChore!.name, 'Bathroom');
      expect(receivedChore.assignees.length, 1);
      expect(receivedChore.assignees.first, member1ID);
      expect(receivedChore.frequency.pattern, Frequency.daily);

      // make sure chore data can be edited
      receivedChore.name = 'edited';
      await upsertChore(receivedChore, house.id);
      final updatedChores = await fetchChores(house.id);
      assert(updatedChores != null);
      expect(updatedChores!.length, 1);
      final updatedChore = updatedChores[receivedChore.id];
      assert(updatedChore != null);
      expect(updatedChore!.name, 'edited');

      // Clean up - delete data
      futures = [
        deleteUser(member1ID),
        deleteUser(member2ID),
        deleteUser(member3ID),
        deleteHouse(house.id),
      ];
      await Future.wait(futures);
      // Make sure all subgroups were deleted
      final deletedChores = await fetchChores(house.id);
      assert(deletedChores == null || deletedChores.isEmpty);
    });

    test('Super chore can be added for a subgroup & deleted', () async {
      // Create three users
      final member1ID = '9508239408304';
      final member2ID = '0850948902432';
      final member3ID = 'fji2u59349032jgf';
      List<Future> futures = [
        createUser(member1ID, 'member1@test.com'),
        createUser(member2ID, 'member1@test.com'),
        createUser(member3ID, 'member1@test.com'),
      ];
      await Future.wait(futures);
      final founder = await fetchUser(member1ID);
      final mem2 = await fetchUser(member2ID);
      final mem3 = await fetchUser(member3ID);
      assert(founder != null);
      assert(mem2 != null);
      assert(mem3 != null);

      // add a house to the db
      final house = House.fromNew(
        houseName: 'Test house!!',
        uid: founder!.id,
        joinCode: '94320483090s',
      );
      await createHouse(founder, house, 'name');
      House? receivedHouse = await fetchHouse(house.id);
      assert(receivedHouse != null);
      // add users to house
      futures = [
        addUserToHouse(mem2!, receivedHouse!.joinCode, 'name'),
        addUserToHouse(mem3!, receivedHouse.joinCode, 'name'),
      ];
      await Future.wait(futures);
      final subgroup = Subgroup.fromNew(
        members: [member3ID, member2ID],
        name: '2 & 3',
        color: Colors.black,
      );
      await upsertSubgroup(subgroup, house.id);

      // Important: we have to handle logic of updating
      // subgroup doc & chore doc

      // now create a chore!!
      final chore = Chore.fromNew(
        name: 'Bathroom',
        pattern: Frequency.daily,
        daysOfWeek: [],
        assignees: [member2ID, member3ID],
        emoji: '🚽',
        description: 'Clean bathroom',
        startDate: DateTime.now(),
      );
      await upsertChore(chore, house.id);
      subgroup.chores.add(chore.id);
      await upsertSubgroup(subgroup, house.id);

      // Now make sure chore data was properly created
      final dbChores = await fetchChores(house.id);
      assert(dbChores != null);
      expect(dbChores!.length, 1);
      final receivedChore = dbChores[chore.id];
      assert(receivedChore != null);
      expect(receivedChore!.name, 'Bathroom');
      expect(receivedChore.assignees.length, 2);
      assert(
        setEquals(receivedChore.assignees.toSet(), {member2ID, member3ID}),
      );
      expect(receivedChore.frequency.pattern, Frequency.daily);

      // check subgroup doc
      final receivedSub = await fetchSubgroup(subgroup.id, house.id);
      assert(receivedSub != null);
      expect(receivedSub!.chores.length, 1);
      expect(receivedSub.chores.first, chore.id);

      // make sure chore data can be deleted
      await deleteChore(houseID: house.id, choreID: chore.id);
      receivedSub.removeChore(chore.id);
      await upsertSubgroup(receivedSub, house.id);
      final newChoresList = await fetchChores(house.id);
      final newSub = await fetchSubgroup(receivedSub.id, house.id);
      assert(newChoresList == null || newChoresList.isEmpty);
      assert(newSub != null);
      assert(newSub!.chores.isEmpty);

      // Clean up - delete data
      futures = [
        deleteUser(member1ID),
        deleteUser(member2ID),
        deleteUser(member3ID),
        deleteHouse(house.id),
      ];
      await Future.wait(futures);
      // Make sure all subgroups were deleted
      final deletedChores = await fetchChores(house.id);
      assert(deletedChores == null || deletedChores.isEmpty);
    });
  });

  group('Chore (instance) tests', () {
    test('Chore instance can be created, assigned, edited, deleted', () async {
      // Create three users
      final member1ID = '9508239408304';
      final member2ID = '0850948902432';
      final member3ID = 'fji2u59349032jgf';
      List<Future> futures = [
        createUser(member1ID, 'member1@test.com'),
        createUser(member2ID, 'member1@test.com'),
        createUser(member3ID, 'member1@test.com'),
      ];
      await Future.wait(futures);
      final founder = await fetchUser(member1ID);
      final mem2 = await fetchUser(member2ID);
      final mem3 = await fetchUser(member3ID);
      assert(founder != null);
      assert(mem2 != null);
      assert(mem3 != null);

      // add a house to the db
      final house = House.fromNew(
        houseName: 'Test house!!',
        uid: founder!.id,
        joinCode: '94320483090s',
      );
      await createHouse(founder, house, 'name');
      House? receivedHouse = await fetchHouse(house.id);
      assert(receivedHouse != null);
      // add users to house
      futures = [
        addUserToHouse(mem2!, receivedHouse!.joinCode, 'name'),
        addUserToHouse(mem3!, receivedHouse.joinCode, 'name'),
      ];
      await Future.wait(futures);

      // Now create super chore
      final chore = Chore.fromNew(
        name: 'Bathroom',
        pattern: Frequency.daily,
        daysOfWeek: [],
        assignees: [member2ID, member3ID],
        emoji: '🚽',
        description: 'Clean bathroom',
        startDate: DateTime.now(),
      );
      await upsertChore(chore, house.id);

      final choreInst1 = ChoreInst.fromNew(
        superCID: chore.id,
        due: DateTime(2025, 5, 20, 11, 59, 59),
        assignee: member1ID,
      );
      final choreInst2 = ChoreInst.fromNew(
        superCID: chore.id,
        due: DateTime(2025, 5, 21, 11, 59, 59),
        assignee: member2ID,
      );
      final choreInst3 = ChoreInst.fromNew(
        superCID: chore.id,
        due: DateTime(2025, 5, 22, 11, 59, 59),
        assignee: member3ID,
      );
      futures = [
        upsertChoreInst(choreInst1, house.id),
        upsertChoreInst(choreInst2, house.id),
        upsertChoreInst(choreInst3, house.id),
      ];
      await Future.wait(futures);

      // Now make sure data was stored properly
      final dbChoreInst = await fetchChoreInstances(house.id);
      assert(dbChoreInst != null && dbChoreInst.isNotEmpty);
      expect(dbChoreInst!.length, 1);
      final dbChoreList = dbChoreInst[chore.id];
      assert(dbChoreList != null);
      expect(dbChoreList!.length, 3);
      assert(dbChoreList.where((c) => c.id == choreInst1.id).isNotEmpty);
      assert(dbChoreList.where((c) => c.id == choreInst2.id).isNotEmpty);
      assert(dbChoreList.where((c) => c.id == choreInst3.id).isNotEmpty);

      // edit chore data & make sure it's replaced
      choreInst1.assignee = member3ID;
      await upsertChoreInst(choreInst1, house.id);
      Map<ChoreID, List<ChoreInst>>? updatedData = await fetchChoreInstances(
        house.id,
      );
      assert(updatedData != null);
      assert(updatedData![chore.id] != null);
      List<ChoreInst> updatedInst =
          updatedData![chore.id]!.where((c) => c.id == choreInst1.id).toList();
      assert(updatedInst.isNotEmpty);
      expect(updatedInst.first.assignee, member3ID);

      // delete chore 2 & make sure we can't find it
      await deleteChoreInst(houseID: house.id, choreInstID: choreInst2.id);
      updatedData = await fetchChoreInstances(house.id);
      assert(updatedData != null);
      assert(updatedData![chore.id] != null);
      updatedInst =
          updatedData![chore.id]!.where((c) => c.id == choreInst2.id).toList();
      assert(updatedInst.isEmpty);

      // test is done, clean up
      futures = [
        deleteUser(member1ID),
        deleteUser(member2ID),
        deleteUser(member3ID),
        deleteHouse(house.id),
      ];
      await Future.wait(futures);
      // Make sure all subgroups were deleted
      final deletedChores = await fetchChores(house.id);
      assert(deletedChores == null || deletedChores.isEmpty);
    });
  });
}
