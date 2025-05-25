// import 'package:divvy/models/chore.dart';
// import 'package:divvy/models/member.dart';
// import 'package:divvy/models/swap.dart';
// import 'package:divvy/providers/divvy_provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';

// class AddSwapScreen extends StatefulWidget {
//   const AddSwapScreen({super.key});

//   @override
//   State<AddSwapScreen> createState() => _AddSwapScreenState();
// }

// class _AddSwapScreenState extends State<AddSwapScreen> {
//   var chosenChoreInstanceIndex = 0;
//   var chosenAssigneeIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DivvyProvider>(
//       builder: (context, provider, child) {
//         List<ChoreInst> choreInstances = provider.getUpcomingChores(
//           provider.currMember.id,
//         );
//         List<Member> possibleRecipients =
//             provider.members
//                 .where((member) => member.id != provider.currMember.id)
//                 .toList();

//         return Scaffold(
//           body:
//               choreInstances.isEmpty || possibleRecipients.isEmpty
//                   ? Center(child: Text("Cannot make swap request"))
//                   : SizedBox.expand(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           CupertinoButton(
//                             child: Text("Submit"),
//                             onPressed: () {},
//                           ),
//                           CupertinoButton(
//                             child: Text("Choose Chore Instance"),
//                             onPressed: () {
//                               selectChore(provider, choreInstances);
//                             },
//                           ),
//                           ListTile(
//                             title: Text(
//                               provider
//                                   .getSuperChore(
//                                     choreInstances[chosenChoreInstanceIndex]
//                                         .superID,
//                                   )!
//                                   .name,
//                             ),
//                             subtitle: Text(
//                               DateFormat.yMMMMd().format(
//                                 choreInstances[chosenChoreInstanceIndex]
//                                     .dueDate,
//                               ),
//                             ),
//                           ),
//                           CupertinoButton(
//                             child: Text("Choose Assignee"),
//                             onPressed: () {
//                               selectAssignee(provider, possibleRecipients);
//                             },
//                           ),
//                           Text(possibleRecipients[chosenAssigneeIndex].name),
//                         ],
//                       ),
//                     ),
//                   ),
//         );
//       },
//     );
//   }

//   startAddSwap(
//     DivvyProvider provider,
//     BuildContext context,
//     List<ChoreInst> choreInstances,
//     List<Member> assignees,
//   ) {
//     Swap swap = Swap(
//       id: Uuid().v4(),
//       choreID: choreInstances[chosenChoreInstanceIndex].superID,
//       choreInstID: choreInstances[chosenChoreInstanceIndex].id,
//       from: provider.currMember.id,
//       to: assignees[chosenAssigneeIndex].id,
//       status: Status.pending,
//     );

//     provider.addSwap(swap, choreInstances[chosenChoreInstanceIndex]);
//   }

//   selectAssignee(DivvyProvider provider, List<Member> assignees) {
//     showCupertinoModalPopup(
//       context: context,
//       builder:
//           (_) => Container(
//             height: 250,
//             color: CupertinoColors.systemBackground.resolveFrom(context),
//             child: Column(
//               children: [
//                 // Done button
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: CupertinoButton(
//                     child: Text('Done'),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ),
//                 // The picker
//                 Expanded(
//                   child: CupertinoPicker(
//                     itemExtent: 32.0,
//                     onSelectedItemChanged: (int index) {
//                       setState(() {
//                         chosenAssigneeIndex = index;
//                       });
//                     },
//                     children: List.generate(assignees.length, (index) {
//                       return Text(assignees[index].name);
//                     }),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   selectChore(DivvyProvider provider, List<ChoreInst> choreInstances) {
//     showCupertinoModalPopup(
//       context: context,
//       builder:
//           (_) => Container(
//             height: 250,
//             color: CupertinoColors.systemBackground.resolveFrom(context),
//             child: Column(
//               children: [
//                 // Done button
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: CupertinoButton(
//                     child: Text('Done'),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ),
//                 // The picker
//                 Expanded(
//                   child: CupertinoPicker(
//                     itemExtent: 32.0,
//                     onSelectedItemChanged: (int index) {
//                       setState(() {
//                         chosenChoreInstanceIndex = index;
//                       });
//                     },
//                     children: List.generate(choreInstances.length, (index) {
//                       return Text(
//                         "${provider.getSuperChore(choreInstances[index].id)!.name} on ${DateFormat.MMMd().format(choreInstances[index].dueDate)}",
//                       );
//                     }),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }
// }
