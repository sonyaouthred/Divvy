import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/models/chore.dart';

// use https://pub.dev/packages/nanoid for joinCode
class Data {
  final house = {
    'id': 'gjkldsjfdklsjfsdfdsa',
    'dateCreated': Timestamp.fromDate(DateTime(2025, 5, 1, 12, 33, 52)),
    'imageID': 'fdskglfhrktlewoirfdsnvn',
    'name': 'Avengers Tower',
    'joinCode': 'lW611f30',
  };

  final members = [
    {
      'id': 'gj343udjkbvjso',
      'name': 'Tony Stark',
      'dateJoined': Timestamp.fromDate(DateTime(2025, 5, 1, 12, 33, 52)),
      'profilePicture': 'darkGreen',
      'onTimePct': '20',
      'email': 'iamironman@avengers.com',
      'chores': ['fjdklt3953oigdss', '4o3u560rihgklfse', 't43iojy4io9ngh'],
      'subgroups': ['gwoiut59432jmgkls', 'jti24tu9042jgssdfds'],
    },
    {
      'id': 'NImZXQblCXQ474vnT8nFeWgZJyg2',
      'name': 'Natasha',
      'dateJoined': Timestamp.fromDate(DateTime(2025, 5, 2, 12, 33, 52)),
      'profilePicture': 'darkGrey',
      'onTimePct': '99',
      'email': 'redacted@avengers.com',
      'chores': ['tji35932jglkmsklgewr', '4o3u560rihgklfse', 't43iojy4io9ngh'],
      'subgroups': ['jti24tu9042jgssdfds'],
    },
    {
      'id': '4392glkslkriep',
      'name': 'Peter Parker',
      'dateJoined': Timestamp.fromDate(DateTime(2025, 5, 3, 12, 33, 52)),
      'profilePicture': 'mediumGreen',
      'onTimePct': '65',
      'email': 'friendlyneighborhoodspiderman@avengers.com',
      'chores': ['fjdklt3953oigdss', '4o3u560rihgklfse', 't43iojy4io9ngh'],
      'subgroups': ['gwoiut59432jmgkls', 'jti24tu9042jgssdfds'],
    },
    {
      'id': 'e4930493jgjg3032',
      'name': 'Nick Fury',
      'dateJoined': Timestamp.fromDate(DateTime(2025, 5, 4, 12, 33, 52)),
      'profilePicture': 'lightGreen',
      'onTimePct': '82',
      'email': 'fury@shield.gov',
      'chores': ['t43iojy4io9ngh'],
      'subgroups': [],
    },
  ];

  final chores = [
    {
      'id': 'fjdklt3953oigdss',
      'name': 'Upstairs bathroom',
      'description':
          'Clean the upstairs bathroom - counters, floors, toilet, and shower. Don\'t forget the sink!',
      'frequencyPattern': Frequency.weekly.name,
      'frequencyDays': ['4'],
      'emoji': '🛁',
      'assignees': ['gj343udjkbvjso', '4392glkslkriep'],
    },
    {
      'id': 'tji35932jglkmsklgewr',
      'name': 'Downstairs bathroom',
      'description':
          'Clean the downstairs bathroom - counters, floors, toilet, and shower. Don\'t forget the sink!',
      'frequencyPattern': Frequency.weekly.name,
      'frequencyDays': ['2', '5'],
      'emoji': '🚽',
      'assignees': ['NImZXQblCXQ474vnT8nFeWgZJyg2'],
    },
    {
      'id': '4o3u560rihgklfse',
      'name': 'Kitchen reset',
      'description':
          'Wipe down the kitchen counters, take out trash/recycling/compost.',
      'frequencyPattern': Frequency.weekly.name,
      'frequencyDays': ['1'],
      'emoji': '🧑‍🍳',
      'assignees': [
        'NImZXQblCXQ474vnT8nFeWgZJyg2',
        'gj343udjkbvjso',
        '4392glkslkriep',
      ],
    },
    {
      'id': 't43iojy4io9ngh',
      'name': 'Battle cleanup',
      'description': 'General cleanup duties after saving the world',
      'frequencyPattern': Frequency.weekly.name,
      'frequencyDays': ['3', '7'],
      'emoji': '🦸',
      'assignees': [
        'e4930493jgjg3032',
        'NImZXQblCXQ474vnT8nFeWgZJyg2',
        'gj343udjkbvjso',
        '4392glkslkriep',
      ],
    },
  ];

  final choreInstances = [
    // upstairs bathroom
    {
      'id': '43u6irohgnklsfe',
      'choreID': 'fjdklt3953oigdss',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 7, 23, 59, 59)),
      'isDone': false,
      'assignee': 'gj343udjkbvjso',
    },
    {
      'id': '4382ht64oiwjgtwep',
      'choreID': 'fjdklt3953oigdss',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 14, 23, 59, 59)),
      'isDone': false,
      'assignee': '4392glkslkriep',
    },
    // downstairs bathroom
    {
      'id': 'gksdgtjew5u320',
      'choreID': 'tji35932jglkmsklgewr',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 5, 23, 59, 59)),
      'isDone': false,
      'assignee': 'NImZXQblCXQ474vnT8nFeWgZJyg2',
    },
    {
      'id': 't4ewoj092u3gvnfgsew',
      'choreID': 'tji35932jglkmsklgewr',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 8, 23, 59, 59)),
      'isDone': false,
      'assignee': 'NImZXQblCXQ474vnT8nFeWgZJyg2',
    },
    // kitchen
    {
      'id': 't4j290tu6j3iqonfgskdg',
      'choreID': '4o3u560rihgklfse',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 4, 23, 59, 59)),
      'isDone': false,
      'assignee': 'NImZXQblCXQ474vnT8nFeWgZJyg2',
    },
    {
      'id': 'eit2ieognklsdmbh',
      'choreID': '4o3u560rihgklfse',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 11, 23, 59, 59)),
      'isDone': false,
      'assignee': 'gj343udjkbvjso',
    },
    {
      'id': 'ghkwr0t6j4320jmklh',
      'choreID': '4o3u560rihgklfse',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 18, 23, 59, 59)),
      'isDone': false,
      'assignee': '4392glkslkriep',
    },
    // battle cleanup
    {
      'id': 'fkdeotj32ignbks',
      'choreID': 't43iojy4io9ngh',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 6, 23, 59, 59)),
      'isDone': false,
      'assignee': 'gj343udjkbvjso',
    },
    {
      'id': 't423u69toingbklfswrew',
      'choreID': 't43iojy4io9ngh',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 10, 23, 59, 59)),
      'isDone': false,
      'assignee': '4392glkslkriep',
    },
    {
      'id': 'q3kopr21jthgrjwe3523',
      'choreID': 't43iojy4io9ngh',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 13, 23, 59, 59)),
      'isDone': false,
      'assignee': 'NImZXQblCXQ474vnT8nFeWgZJyg2',
    },
    {
      'id': 't4h23oingmfsngioewt',
      'choreID': 't43iojy4io9ngh',
      'dueDate': Timestamp.fromDate(DateTime(2025, 5, 17, 23, 59, 59)),
      'isDone': false,
      'assignee': 'e4930493jgjg3032',
    },
  ];

  final subgroups = [
    {
      'id': 'gwoiut59432jmgkls',
      'name': 'Tony & Peter',
      'profilePicture': 'red',
      'members': ['gj343udjkbvjso', '4392glkslkriep'],
      'chores': ['fjdklt3953oigdss'],
    },
    {
      'id': 'jti24tu9042jgssdfds',
      'name': 'Avengers',
      'profilePicture': 'lightGreen',
      'members': [
        'gj343udjkbvjso',
        '4392glkslkriep',
        'NImZXQblCXQ474vnT8nFeWgZJyg2',
      ],
      'chores': ['4o3u560rihgklfse'],
    },
  ];
}
