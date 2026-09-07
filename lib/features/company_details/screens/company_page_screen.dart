import 'package:eClassify/core/models/company_details.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CompanyPageScreen extends StatelessWidget {
  const CompanyPageScreen({required this.page, super.key});

  final CompanyPage page;

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) =>
          CompanyPageScreen(page: routeSettings.arguments as CompanyPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Constant.systemSettings.companyDetails.pages
        .getPageFromType(page);
    return Scaffold(
      appBar: AppBar(title: Text(page.name.translate(context))),
      body: Padding(
        padding: Constant.appContentPadding,
        child: content.isNullOrEmpty
            ? Center(child: QErrorWidget.emptyData())
            : SingleChildScrollView(child: HtmlWidget(content!)),
      ),
    );
  }
}
