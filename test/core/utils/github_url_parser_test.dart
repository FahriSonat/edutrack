import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/utils/github_url_parser.dart';

void main() {
  group('GithubUrlParser Tests', () {
    test('standard https url parses successfully', () {
      final res = GithubUrlParser.parse('https://github.com/flutter/flutter');
      expect(res, isNotNull);
      expect(res!.owner, 'flutter');
      expect(res.repo, 'flutter');
    });

    test('url with .git suffix cleans .git', () {
      final res = GithubUrlParser.parse('https://github.com/torvalds/linux.git');
      expect(res, isNotNull);
      expect(res!.owner, 'torvalds');
      expect(res.repo, 'linux');
    });

    test('url with trailing slash parses correctly', () {
      final res = GithubUrlParser.parse('https://github.com/google/material-design-icons/');
      expect(res, isNotNull);
      expect(res!.owner, 'google');
      expect(res.repo, 'material-design-icons');
    });

    test('url without protocol (github.com/user/repo) parses correctly', () {
      final res = GithubUrlParser.parse('github.com/octocat/Hello-World');
      expect(res, isNotNull);
      expect(res!.owner, 'octocat');
      expect(res.repo, 'Hello-World');
    });

    test('invalid domains return null', () {
      final res = GithubUrlParser.parse('https://gitlab.com/user/repo');
      expect(res, isNull);
    });

    test('empty or malformed strings return null', () {
      expect(GithubUrlParser.parse(''), isNull);
      expect(GithubUrlParser.parse('https://github.com/onlyuser'), isNull);
      expect(GithubUrlParser.parse('not a url'), isNull);
    });
  });
}

