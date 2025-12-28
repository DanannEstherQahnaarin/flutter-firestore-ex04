import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';
import 'package:flutter_firestore_ex04/pages/page_post_update.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/service/service_post.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _canEdit() {
    final authProvider = context.read<AuthProvider>();
    return authProvider.isAdmin ||
        (authProvider.isAuthenticated &&
            authProvider.currentUser?.uid == widget.post.writerId);
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _canEdit();

    return Scaffold(
      appBar: buildCommonAppBar(context, '게시글 상세'),
      body: _buildDetailView(isEdit: canEdit),
    );
  }

  Widget _buildDetailView({bool isEdit = false}) => SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.post.isNotice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '공지',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          widget.post.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '작성자: ${widget.post.writerNickname}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Text('조회수: ${widget.post.viewCount}', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '작성일: ${widget.post.createdAt.toString().substring(0, 19)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const Divider(height: 32),
        if (widget.post.thumbnailUrl != null) ...[
          Image.network(widget.post.thumbnailUrl!, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 350,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Text(widget.post.content, style: const TextStyle(fontSize: 16)),
          ),
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isEdit) ...[
              ElevatedButton(
                onPressed: () {
                  // 원래 context를 저장 (dialog가 닫힌 후에도 사용하기 위해)
                  final navigatorContext = Navigator.of(context);

                  showCommonAlertDialog(
                    context: context,
                    title: 'Delete',
                    content: '삭제하시겠습니까?',
                    onPositivePressed: () async {
                      final result = await PostService().deletePost(
                        context: context,
                        postId: widget.post.id,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: result.success ? Colors.green : Colors.red,
                        ),
                      );

                      // 삭제 성공 시 리스트 페이지로 돌아가기
                      if (result.success && mounted) {
                        // PostDetailPage를 닫아서 리스트 페이지로 돌아감
                        navigatorContext.pop();
                      }
                    },
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.remove, color: Colors.red),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostUpdatePage(post: widget.post)),
                  ).then((_) {
                    // 업데이트 페이지에서 돌아왔을 때 상태 새로고침
                    setState(() {});
                  });
                },
                child: const Row(children: [Icon(Icons.edit), Text('Edit')]),
              ),
            ] else
              const SizedBox.shrink(),
            // Padding(
            //   padding: const EdgeInsets.all(10),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       InputDecorator(
            //         decoration: const InputDecoration(
            //           labelText: 'Member Join', // 상단 타이틀
            //           border: OutlineInputBorder(), // 테두리
            //           contentPadding: EdgeInsets.all(20), // 테두리와 내부 위젯 사이의 여백
            //         ),
            //         child: Form(
            //           child: Column(
            //             children: [
            //               const Icon(Icons.comment),
            //               commonFormText(
            //                 controller: txtCommentController,
            //                 labelText: 'Comment',
            //               ),
            //               IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            //             ],
            //           ),
            //         ),
            //       ),
            //       StreamBuilder(
            //         stream: null,
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.waiting) {
            //             return const Center(child: CircularProgressIndicator());
            //           }

            //           final comments = snapshot.data;

            //           return ListView.separated(
            //             itemBuilder: (context, index) {},
            //             separatorBuilder: (context, index) => const Divider(),
            //             itemCount: 1,
            //           );
            //         },
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ],
    ),
  );
}
