import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_listview.dart';
import 'package:flutter_firestore_ex04/models/model_user.dart';
import 'package:flutter_firestore_ex04/service/service_auth.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: buildCommonAppBar(context, '사용자 목록'),
      body: StreamBuilder(
        stream: authService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data;

          if (users == null) {
            return const Center(child: Text('No DATA'));
          }

          return buildCommonListView<UserModel>(
            items: users,
            itemBuilder: (context, index, user) {
              return ListTile(
                title: Text('${user.nickName}(${user.role})'),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.admin_panel_settings)),
                    IconButton(
                      onPressed: () {
                        showCommonAlertDialog(
                          context: context,
                          title: '삭제',
                          content: '${user.nickName}을 삭제하시겠습니까?',
                          onPositivePressed: () => authService.deleteUser(user.uid),
                        );
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
