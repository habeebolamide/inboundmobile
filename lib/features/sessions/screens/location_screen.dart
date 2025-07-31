import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// import 'location_picker.dart'; // Import the LocationPicker widget
import 'package:http/http.dart' as http;
import 'dart:convert';

@RoutePage()
class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});


  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  bool _loading = false;
  final _form = {
    'title': '',
    'group_id': '',
    'supervisor_id': '',
    'latitude': '',
    'longitude': '',
    'radius': '50',
    'start_time': '',
    'end_time': '',
    'building_name': '',
  };
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _supervisors = [];

  @override
  void initState() {
    super.initState();
    // _fetchOrgGroups();
    // _fetchOrgSupervisors();
  }

  void _resetForm() {
    setState(() {
      _form.clear();
      _form.addAll({
        'title': '',
        'group_id': '',
        'supervisor_id': '',
        'latitude': '',
        'longitude': '',
        'radius': '50',
        'start_time': '',
        'end_time': '',
        'building_name': '',
      });
    });
  }

  Future<void> _createSession() async {
    setState(() => _loading = true);
    try {
      // Replace with your API endpoint
      final response = await http.post(
        Uri.parse('https://your-api/v1/organization/sessions/create'),
        body: json.encode(_form),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created successfully!')),
        );
        _resetForm();
      } else {
        throw Exception('Failed to create session');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create session: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Future<void> _fetchOrgGroups() async {
  //   try {
  //     // Replace with your API endpoint
  //     final response = await http.get(
  //       Uri.parse('https://your-api/v1/organization/groups/get_org_groups'),
  //     );
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _groups = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching groups: $e');
  //   }
  // }

  // Future<void> _fetchOrgSupervisors() async {
  //   try {
  //     // Replace with your API endpoint
  //     final response = await http.get(
  //       Uri.parse('https://your-api/v1/organization/supervisors/getOrganizationSupervisors'),
  //     );
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _supervisors = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching supervisors: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 1000,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create Session',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Fill in session details below.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 400,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    enabled: !_loading,
                    onChanged: (value) => _form['title'] = value,
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Group'),
                    disabledHint: const Text('Loading...'),
                    items: _groups.map((group) {
                      return DropdownMenuItem(
                        value: group['id'].toString(),
                        child: Text(group['name']),
                      );
                    }).toList(),
                    onChanged: _loading
                        ? null
                        : (value) => _form['group_id'] = value ?? '',
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Supervisor'),
                    disabledHint: const Text('Loading...'),
                    items: _supervisors.map((supervisor) {
                      return DropdownMenuItem(
                        value: supervisor['id'].toString(),
                        child: Text(supervisor['name']),
                      );
                    }).toList(),
                    onChanged: _loading
                        ? null
                        : (value) => _form['supervisor_id'] = value ?? '',
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Radius (m)'),
                    keyboardType: TextInputType.number,
                    enabled: !_loading,
                    onChanged: (value) => _form['radius'] = value,
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Start Time'),
                    enabled: !_loading,
                    onTap: () async {
                      final dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (dateTime != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final finalDateTime = DateTime(
                            dateTime.year,
                            dateTime.month,
                            dateTime.day,
                            time.hour,
                            time.minute,
                          );
                          _form['start_time'] = finalDateTime.toIso8601String();
                        }
                      }
                    },
                    readOnly: true,
                    // controller: TextEditingController(
                    //   text: _form['start_time'].isNotEmpty
                    //       ? DateTime.parse(_form['start_time']).toString()
                    //       : '',
                    // ),
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'End Time'),
                    enabled: !_loading,
                    onTap: () async {
                      final dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (dateTime != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final finalDateTime = DateTime(
                            dateTime.year,
                            dateTime.month,
                            dateTime.day,
                            time.hour,
                            time.minute,
                          );
                          _form['end_time'] = finalDateTime.toIso8601String();
                        }
                      }
                    },
                    readOnly: true,
                    // controller: TextEditingController(
                    //   text: _form['end_time'].isNotEmpty
                    //       ? DateTime.parse(_form['end_time']).toString()
                    //       : '',
                    // ),
                  ),
                ),
                SizedBox(
                  width: 816,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Building Name'),
                    enabled: false,
                    controller: TextEditingController(text: _form['building_name']),
                  ),
                ),
                SizedBox(
                  width: 816,
                  // child: LocationPicker(
                  //   onLatitudeChanged: (lat) => _form['latitude'] = lat.toString(),
                  //   onLongitudeChanged: (lng) => _form['longitude'] = lng.toString(),
                  //   onLocationNameChanged: (name) => _form['building_name'] = name,
                  // ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextButton(
                //   onPressed: _loading ? null : () => widget.onVisibilityChanged(false),
                //   child: const Text('Close'),
                // ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _createSession,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}