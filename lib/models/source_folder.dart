import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';

class SourceFolder extends Equatable{
  final String sourceFolderName;
  final List<Source> sourceList;
  SourceFolder({this.sourceFolderName, this.sourceList}):
      super([sourceFolderName, sourceList]);
}