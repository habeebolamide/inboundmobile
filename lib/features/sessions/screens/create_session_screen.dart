import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:inboundmobile/app/router/app_router.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:inboundmobile/core/helpers/%20snackbar_helper.dart';
import 'package:inboundmobile/core/helpers/loader_utils.dart';
import 'package:inboundmobile/core/services/api_service.dart';
import 'package:inboundmobile/features/dashboard/data/session_repository.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';

@RoutePage()
class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  bool _loading = false;
  bool _createloading = false;
  final _formKey = GlobalKey<FormState>();
  final SessionModel _form = SessionModel(); 
  final SessionRepository _session = SessionRepository();
  final _api = ApiService();

  List<dynamic> groups = [];
  String? selectedGroup;

  // Controllers for text fields
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // DateTime picker method
  Future<void> _pickDateTime(Function(DateTime) updateCallback) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((pickedDate) async {
      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          return DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }
      return null;
    });

    if (pickedDateTime != null) {
      updateCallback(pickedDateTime);
    }
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
    });
    final response = await _api.get('/v1/organization/groups/get_org_groups');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        groups = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load groups')));
    }
  }

  // Fetch Current Location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied forever.')),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied.')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _form.latitude = position.latitude;
        _form.longitude = position.longitude;

        // Update the controllers with new values
        _latitudeController.text = _form.latitude.toString();
        _longitudeController.text = _form.longitude.toString();

        print('Latitude: ${_form.latitude}, Longitude: ${_form.longitude}'); // Debugging
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching location: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          
          child: _createloading ? CustomLoader() : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Fill in session details below.'),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _form.title,
                  decoration: InputDecoration(labelText: 'Title'),
                  onChanged: (value) => _form.title = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a session title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedGroup ?? _form.groupId?.toString(),
                  decoration: InputDecoration(labelText: 'Group'),
                  items: groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group['id'].toString(),
                      child: Text(group['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _form.groupId = int.tryParse(value ?? '');
                      selectedGroup = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a group';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: _form.radius?.toString(),
                  decoration: InputDecoration(labelText: 'Radius (m)'),
                  onChanged: (value) => _form.radius = int.tryParse(value),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a radius';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // Start Time
                TextFormField(
                  controller: _startTimeController,
                  decoration: InputDecoration(labelText: 'Start Time'),
                  readOnly: true,
                  onTap: () => _pickDateTime((startTime) {
                    setState(() {
                      _form.startTime = startTime;
                      _startTimeController.text = startTime.toLocal().toString().split(' ')[0] + ' ' + startTime.toLocal().toString().split(' ')[1].substring(0, 5);  // Formatting
                    });
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a start time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // End Time
                TextFormField(
                  controller: _endTimeController,
                  decoration: InputDecoration(labelText: 'End Time'),
                  readOnly: true,
                  onTap: () => _pickDateTime((endTime) {
                    setState(() {
                      _form.endTime = endTime;
                      _endTimeController.text = endTime.toLocal().toString().split(' ')[0] + ' ' + endTime.toLocal().toString().split(' ')[1].substring(0, 5);  // Formatting
                    });
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an end time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: _form.location,
                  decoration: InputDecoration(labelText: 'Building Name'),
                  onChanged: (value) => _form.location = value,
                ),
                const SizedBox(height: 10),
                // Latitude Field
                TextFormField(
                  controller: _latitudeController,
                  decoration: InputDecoration(labelText: 'Latitude'),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                // Longitude Field
                TextFormField(
                  controller: _longitudeController,
                  decoration: InputDecoration(labelText: 'Longitude'),
                  readOnly: true,
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text('Use Current Location'),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                     if (_formKey.currentState!.validate()) {
                      // Submit the session data
                      setState(() {
                        _createloading = true;
                      });
                      final message = await _session.createSession(_form);
                      if (message != null) {
                        showSnackBar(context, message.toString(), AppColors.error);
                      }
                      showSnackBar(context, 'Session Created', AppColors.success);
                      setState(() {
                        _createloading = false;
                      });
                      context.router.replace(DashboardRoute());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: _createloading
                            ? Center(child: CircularProgressIndicator())
                            :Text('Create Session', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
