import 'package:flutter/material.dart';
import '../Model/CourceModel.dart';
import 'StudentProgressScreen.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;
  final Enrollment enrollment;
  final Course? course;

  const UserDetailScreen({
    required this.user,
    required this.enrollment,
    this.course,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('User Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Add more actions like edit, contact, etc.
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with User Avatar and Basic Info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // User Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(user.image.imageUrl),
                        backgroundColor: Colors.grey[300],
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image error
                        },
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // User Name
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 8),
                    
                    // User Email
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Role Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        user.role.replaceAll('ROLE_', ''),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content Section
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Card
                  _buildInfoCard(
                    title: 'Personal Information',
                    icon: Icons.person,
                    children: [
                      _buildInfoRow('User ID', '${user.userId}'),
                      _buildInfoRow('First Name', user.firstName),
                      _buildInfoRow('Last Name', user.lastName),
                      _buildInfoRow('Email Address', user.email),
                      _buildInfoRow('Account Status', user.enabled ? 'Active' : 'Inactive', 
                          valueColor: user.enabled ? Colors.green : Colors.red),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Enrollment Information Card
                  _buildInfoCard(
                    title: 'Enrollment Information',
                    icon: Icons.school,
                    children: [
                      _buildInfoRow('Enrollment ID', '${enrollment.enrollmentId}'),
                      _buildInfoRow('Course ID', '${enrollment.courseId}'),
                      if (course != null) _buildInfoRow('Course Name', course!.courseName),
                      _buildInfoRow('Enrollment Status', 
                          enrollment.completed ? 'Completed' : 'In Progress',
                          valueColor: enrollment.completed ? Colors.green : Colors.orange),
                      _buildInfoRow('Progress', enrollment.completed ? '100%' : '0%'),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Account Information Card
                  _buildInfoCard(
                    title: 'Account Information',
                    icon: Icons.account_circle,
                    children: [
                      _buildInfoRow('Role', user.role.replaceAll('ROLE_', '')),
                      _buildInfoRow('Account Type', _getAccountType(user.role)),
                      _buildInfoRow('Profile Image', user.image.fileName),
                      _buildInfoRow('Image URL', user.image.imageUrl, isUrl: true),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Action Buttons
                  Column(
                    children: [
                      // View Progress Button (Primary Action)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentProgressScreen(
                                  user: user,
                                  enrollment: enrollment,
                                  course: course,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.trending_up),
                          label: Text('View Progress'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Secondary Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Add contact functionality
                                _showContactOptions(context);
                              },
                              icon: Icon(Icons.message),
                              label: Text('Contact'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Add view profile functionality
                                _showProfileOptions(context);
                              },
                              icon: Icon(Icons.visibility),
                              label: Text('More Options'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[600],
                                side: BorderSide(color: Colors.blue[600]!),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Additional Information Card
                  _buildInfoCard(
                    title: 'Additional Information',
                    icon: Icons.info,
                    children: [
                      _buildInfoRow('Image ID', '${user.image.imageId}'),
                      _buildInfoRow('Content Type', user.image.contentType),
                      _buildInfoRow('Object Name', user.image.objectName),
                      _buildInfoRow('File Name', user.image.fileName),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isUrl = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isUrl 
                ? SelectableText(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: valueColor ?? Colors.blue[600],
                      decoration: TextDecoration.underline,
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: valueColor ?? Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getAccountType(String role) {
    switch (role) {
      case 'ROLE_STUDENT':
        return 'Student Account';
      case 'ROLE_INSTRUCTOR':
        return 'Instructor Account';
      case 'ROLE_ADMIN':
        return 'Administrator Account';
      default:
        return 'Unknown Account';
    }
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact ${user.firstName}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.email, color: Colors.blue[600]),
                title: Text('Send Email'),
                subtitle: Text(user.email),
                onTap: () {
                  Navigator.pop(context);
                  // Implement email functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.message, color: Colors.green[600]),
                title: Text('Send Message'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement messaging functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Profile Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue[600]),
                title: Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement edit profile functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.orange[600]),
                title: Text('View Activity'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement activity view functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.assessment, color: Colors.purple[600]),
                title: Text('View Progress'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement progress view functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
