import 'package:divvy/util/server_util.dart';
import 'package:flutter_test/flutter_test.dart';

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
    test('User can be added to a house (does not check house data)', () async {
      // Create a generic user
      final userID = '8590480294134';
      final email = 'test@test.edu';
      await createUser(userID, email);
      final receivedUser = await fetchUser(userID);
      assert(receivedUser != null);
      // Assert data is correct
      expect(receivedUser!.email, email);
      expect(receivedUser.houseID, '');

      // now add user to a house
      final houseJoinCode = 'lW611f30';
      final houseID = 'gjkldsjfdklsjfsdfdsa';
      await addUserToHouse(receivedUser, houseJoinCode);
      // Verify updates worked
      final updatedUser = await fetchUser(userID);
      assert(updatedUser != null);
      // Assert data is correct
      expect(updatedUser!.email, email);
      expect(updatedUser.houseID, houseID);
      expect(updatedUser.id, userID);

      // Clean up - delete data
      await deleteUser(userID);
      final deletedUserData = await fetchUser(userID);
      assert(deletedUserData == null);
    });
  });
}
