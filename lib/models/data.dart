import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:flutter/material.dart';

class Data {
  final house = {
    'id': 'gjkldsjfdklsjfsdfdsa',
    'dateCreated': DateTime(2025, 5, 1, 12, 33, 52),
    'imageID': 'fdskglfhrktlewoirfdsnvn',
    'name': 'Avengers Tower',
    'members': [
      'gj343udjkbvjso',
      '24889rhgksje',
      '4392glkslkriep',
      'e4930493jgjg3032',
    ],
  };

  final members = [
    {
      'id': 'gj343udjkbvjso',
      'name': 'Tony Stark',
      'dateJoined': DateTime(2025, 5, 1, 12, 33, 52),
      'profilePicture': DivvyTheme.darkGreen,
      'onTimePct': 20,
      'email': 'iamironman@avengers.com',
      'chores': ['fjdklt3953oigdss', '4o3u560rihgklfse', 't43iojy4io9ngh'],
      'subgroups': ['gwoiut59432jmgkls', 'jti24tu9042jgssdfds'],
    },
    {
      'id': '24889rhgksje',
      'name': 'Natasha',
      'dateJoined': DateTime(2025, 5, 2, 12, 33, 52),
      'profilePicture': DivvyTheme.darkGrey,
      'onTimePct': 99,
      'email': 'redacted@avengers.com',
      'chores': ['tji35932jglkmsklgewr', '4o3u560rihgklfse', 't43iojy4io9ngh'],
      'subgroups': ['jti24tu9042jgssdfds'],
    },
    {
      'id': '4392glkslkriep',
      'name': 'Peter Parker',
      'dateJoined': DateTime(2025, 5, 3, 12, 33, 52),
      'profilePicture': DivvyTheme.mediumGreen,
      'onTimePct': 65,
      'email': 'friendlyneighborhoodspiderman@avengers.com',
      'chores': ['fjdklt3953oigdss', '4o3u560rihgklfse', 't43iojy4io9ngh'],
      'subgroups': ['gwoiut59432jmgkls', 'jti24tu9042jgssdfds'],
    },
    {
      'id': 'e4930493jgjg3032',
      'name': 'Nick Fury',
      'dateJoined': DateTime(2025, 5, 4, 12, 33, 52),
      'profilePicture': DivvyTheme.lightGreen,
      'onTimePct': 82,
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
      'frequency': Frequency.weekly.name,
      'dayOfWeek': [4],
      'instances': ['43u6irohgnklsfe', '4382ht64oiwjgtwep'],
      'emoji': '🛁',
      'assignees': ['gj343udjkbvjso', '4392glkslkriep'],
    },
    {
      'id': 'tji35932jglkmsklgewr',
      'name': 'Downstairs bathroom',
      'description':
          'Clean the downstairs bathroom - counters, floors, toilet, and shower. Don\'t forget the sink!',
      'frequency': Frequency.weekly.name,
      'dayOfWeek': [2, 5],
      'instances': ['gksdgtjew5u320', 't4ewoj092u3gvnfgsew'],
      'emoji': '🚽',
      'assignees': ['24889rhgksje'],
    },
    {
      'id': '4o3u560rihgklfse',
      'name': 'Kitchen reset',
      'description':
          'Wipe down the kitchen counters, take out trash/recycling/compost.',
      'frequency': Frequency.weekly.name,
      'dayOfWeek': [1],
      'instances': [
        't4j290tu6j3iqonfgskdg',
        'eit2ieognklsdmbh',
        'ghkwr0t6j4320jmklh',
      ],
      'emoji': '🧑‍🍳',
      'assignees': ['24889rhgksje', 'gj343udjkbvjso', '4392glkslkriep'],
    },
    {
      'id': 't43iojy4io9ngh',
      'name': 'Battle cleanup',
      'description': 'General cleanup duties after saving the world',
      'frequency': Frequency.weekly.name,
      'dayOfWeek': [3, 7],
      'instances': [
        'fkdeotj32ignbks',
        't423u69toingbklfswrew',
        'q3kopr21jthgrjwe3523',
        't4h23oingmfsngioewt',
      ],
      'emoji': '🦸',
      'assignees': [
        'e4930493jgjg3032',
        '24889rhgksje',
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
      'dueDate': DateTime(2025, 5, 7, 23, 59, 59),
      'isDone': false,
      'assignee': 'gj343udjkbvjso',
    },
    {
      'id': '4382ht64oiwjgtwep',
      'choreID': 'fjdklt3953oigdss',
      'dueDate': DateTime(2025, 5, 14, 23, 59, 59),
      'isDone': false,
      'assignee': '4392glkslkriep',
    },
    // downstairs bathroom
    {
      'id': 'gksdgtjew5u320',
      'choreID': 'tji35932jglkmsklgewr',
      'dueDate': DateTime(2025, 5, 5, 23, 59, 59),
      'isDone': false,
      'assignee': '24889rhgksje',
    },
    {
      'id': 't4ewoj092u3gvnfgsew',
      'choreID': 'tji35932jglkmsklgewr',
      'dueDate': DateTime(2025, 5, 8, 23, 59, 59),
      'isDone': false,
      'assignee': '24889rhgksje',
    },
    // kitchen
    {
      'id': 't4j290tu6j3iqonfgskdg',
      'choreID': '4o3u560rihgklfse',
      'dueDate': DateTime(2025, 5, 4, 23, 59, 59),
      'isDone': false,
      'assignee': '24889rhgksje',
    },
    {
      'id': 'eit2ieognklsdmbh',
      'choreID': '4o3u560rihgklfse',
      'dueDate': DateTime(2025, 5, 11, 23, 59, 59),
      'isDone': false,
      'assignee': 'gj343udjkbvjso',
    },
    {
      'id': 'ghkwr0t6j4320jmklh',
      'choreID': '4o3u560rihgklfse',
      'dueDate': DateTime(2025, 5, 18, 23, 59, 59),
      'isDone': false,
      'assignee': '4392glkslkriep',
    },
    // battle cleanup
    {
      'id': 'fkdeotj32ignbks',
      'choreID': 't43iojy4io9ngh',
      'dueDate': DateTime(2025, 5, 6, 23, 59, 59),
      'isDone': false,
      'assignee': 'gj343udjkbvjso',
    },
    {
      'id': 't423u69toingbklfswrew',
      'choreID': 't43iojy4io9ngh',
      'dueDate': DateTime(2025, 5, 10, 23, 59, 59),
      'isDone': false,
      'assignee': '4392glkslkriep',
    },
    {
      'id': 'q3kopr21jthgrjwe3523',
      'choreID': 't43iojy4io9ngh',
      'dueDate': DateTime(2025, 5, 13, 23, 59, 59),
      'isDone': false,
      'assignee': '24889rhgksje',
    },
    {
      'id': 't4h23oingmfsngioewt',
      'choreID': 't43iojy4io9ngh',
      'dueDate': DateTime(2025, 5, 17, 23, 59, 59),
      'isDone': false,
      'assignee': 'e4930493jgjg3032',
    },
  ];

  final subgroups = [
    {
      'id': 'gwoiut59432jmgkls',
      'name': 'Tony & Peter',
      'profilePicture': Colors.red,
      'members': ['gj343udjkbvjso', '4392glkslkriep'],
      'chores': ['fjdklt3953oigdss'],
    },
    {
      'id': 'jti24tu9042jgssdfds',
      'name': 'Avengers',
      'profilePicture': Colors.lightGreen,
      'members': ['gj343udjkbvjso', '4392glkslkriep', '24889rhgksje'],
      'chores': ['4o3u560rihgklfse'],
    },
  ];
}
