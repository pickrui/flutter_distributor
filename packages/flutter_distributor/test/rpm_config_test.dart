import 'package:flutter_app_packager/src/makers/rpm/make_rpm_config.dart';
import 'package:test/test.dart';

void main() {
  test('rpm preserves explicit macros, dependency and lifecycle scripts', () {
    final config = MakeRPMConfig.fromJson({
      'display_name': 'Sample',
      'requires': ['libsecret'],
      'spec_macros': [
        '%global debug_package %{nil}',
        '%global __os_install_post %{nil}'
      ],
      'postinstall_scripts': ['prepare_helper', 'refresh_desktop'],
      'postuninstall_scripts': ['retire_helper'],
    });
    final spec = config.toFilesString()['SPEC']!;
    expect(
        spec,
        startsWith(
            '%global debug_package %{nil}\n%global __os_install_post %{nil}\nName:'));
    expect(spec, contains('Requires: libsecret\n'));
    expect(spec, contains('%post\nprepare_helper\nrefresh_desktop\n'));
    expect(spec, contains('\nretire_helper\n'));
  });

  test('rpm without optional macros and scripts preserves the default spec',
      () {
    final spec = MakeRPMConfig.fromJson({'display_name': 'Sample'})
        .toFilesString()['SPEC']!;
    expect(spec, startsWith('Name:'));
    expect(spec, isNot(contains('%post\n')));
    expect(spec, contains('%postun\nupdate-mime-database'));
  });
}
