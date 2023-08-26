// A simple course table app
// Copyright (C) 2023 Zhihao Zhou
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

class SemesterInfo {
  final String value;
  final String index;
  final String semesterId1;
  final String semesterId2;

  const SemesterInfo(
      {required this.value,
      required this.index,
      required this.semesterId1,
      required this.semesterId2});

  factory SemesterInfo.fromJson(Map<String, dynamic> json) {
    return SemesterInfo(
        value: json['Value'].toString(),
        index: json['Index'].toString(),
        semesterId1: json['SemesterId1'].toString(),
        semesterId2: json['SemesterId2'].toString());
  }
}
