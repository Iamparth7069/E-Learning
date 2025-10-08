import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/CourceModel.dart';
import '../Controller/CateogryController.dart';

class StudentProgressScreen extends StatelessWidget {
  final User user;
  final Enrollment enrollment;
  final Course? course;

  const StudentProgressScreen({
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
        title: Text('Student Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Add refresh functionality
              Get.find<CourseManagment>().getEnrollmentProgress(enrollment.enrollmentId);
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: GetBuilder<CourseManagment>(
        init: CourseManagment(),
        builder: (controller) {
          // Load progress when screen opens
          if (controller.enrollmentProgress == 0.0 && !controller.isLoadingProgress) {
            controller.getEnrollmentProgress(enrollment.enrollmentId);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with User Info
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
                            radius: 50,
                            backgroundImage: NetworkImage(user.image.imageUrl),
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // User Name
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 8),
                        
                        // Course Name
                        if (course != null)
                          Text(
                            course!.courseName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Progress Section
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Overview Card
                      _buildProgressOverviewCard(controller),
                      
                      SizedBox(height: 20),
                      
                      // Detailed Progress Card
                      _buildDetailedProgressCard(controller),
                      
                      SizedBox(height: 20),
                      
                      // Enrollment Information Card
                      _buildEnrollmentInfoCard(),
                      
                      SizedBox(height: 20),
                      
                      // Progress Statistics Card
                      _buildProgressStatsCard(controller),
                      
                      SizedBox(height: 20),
                      
                      // Action Buttons
                      _buildActionButtons(context, controller),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressOverviewCard(CourseManagment controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Course Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Progress Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Circle
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                  ),
                  
                  // Progress Circle
                  if (controller.isLoadingProgress)
                    CircularProgressIndicator(
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    )
                  else
                    CircularProgressIndicator(
                      value: controller.enrollmentProgress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(controller.enrollmentProgress),
                      ),
                    ),
                  
                  // Progress Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.isLoadingProgress 
                            ? '...' 
                            : '${(controller.enrollmentProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      controller.isLoadingProgress 
                          ? 'Loading...' 
                          : '${(controller.enrollmentProgress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getProgressColor(controller.enrollmentProgress),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: controller.isLoadingProgress ? null : controller.enrollmentProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(controller.enrollmentProgress),
                  ),
                  minHeight: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedProgressCard(CourseManagment controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Progress Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Progress Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Completed',
                    controller.isLoadingProgress 
                        ? '...' 
                        : '${(controller.enrollmentProgress * 100).toInt()}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Remaining',
                    controller.isLoadingProgress 
                        ? '...' 
                        : '${(100 - (controller.enrollmentProgress * 100)).toInt()}%',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Status Information
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getProgressColor(controller.enrollmentProgress).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getProgressColor(controller.enrollmentProgress).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getProgressIcon(controller.enrollmentProgress),
                    color: _getProgressColor(controller.enrollmentProgress),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getProgressStatus(controller.enrollmentProgress),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getProgressColor(controller.enrollmentProgress),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _getProgressDescription(controller.enrollmentProgress),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school,
                    color: Colors.purple[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Enrollment Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            _buildInfoRow('Enrollment ID', '${enrollment.enrollmentId}'),
            _buildInfoRow('User ID', '${user.userId}'),
            _buildInfoRow('Course ID', '${enrollment.courseId}'),
            if (course != null) _buildInfoRow('Course Name', course!.courseName),
            _buildInfoRow('Student Name', user.fullName),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Enrollment Status', 
                enrollment.completed ? 'Completed' : 'In Progress',
                valueColor: enrollment.completed ? Colors.green : Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStatsCard(CourseManagment controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: Colors.orange[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Progress Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Progress Score',
                    controller.isLoadingProgress 
                        ? '...' 
                        : '${(controller.enrollmentProgress * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Completion',
                    controller.isLoadingProgress 
                        ? '...' 
                        : enrollment.completed ? '100%' : '${(controller.enrollmentProgress * 100).toInt()}%',
                    Icons.flag,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CourseManagment controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              controller.getEnrollmentProgress(enrollment.enrollmentId);
            },
            icon: Icon(Icons.refresh),
            label: Text('Refresh Progress'),
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
              // Navigate back to user detail screen
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            label: Text('Back to Profile'),
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
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
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
            child: Text(
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

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    if (progress >= 0.2) return Colors.blue;
    return Colors.red;
  }

  IconData _getProgressIcon(double progress) {
    if (progress >= 0.8) return Icons.check_circle;
    if (progress >= 0.5) return Icons.trending_up;
    if (progress >= 0.2) return Icons.play_circle;
    return Icons.schedule;
  }

  String _getProgressStatus(double progress) {
    if (progress >= 0.8) return 'Excellent Progress';
    if (progress >= 0.5) return 'Good Progress';
    if (progress >= 0.2) return 'Getting Started';
    return 'Just Started';
  }

  String _getProgressDescription(double progress) {
    if (progress >= 0.8) return 'Student is making excellent progress in the course';
    if (progress >= 0.5) return 'Student is on track with good progress';
    if (progress >= 0.2) return 'Student has started the course';
    return 'Student has just enrolled in the course';
  }
}
