import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/LessonDetailController.dart';
import 'package:chewie/chewie.dart';

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    final lessonId = args?['lessonId'] as int?;
    final lessonName = args?['lessonName'] as String?;
    final courseName = args?['courseName'] as String?;
    final enrollmentId = args?['enrollmentId'] as int?;
    
    // Initialize controller with arguments
    final LessonDetailController controller = Get.put(
      LessonDetailController(
        lessonId: lessonId,
        lessonName: lessonName,
        courseName: courseName,
        enrollmentId: enrollmentId,
      ),
    );
    
    // Handle back button to properly dispose controller
    return WillPopScope(
      onWillPop: () async {
        // Dispose controller when going back
        Get.delete<LessonDetailController>();
        return true;
      },
      child: Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Obx(() => Text(
          controller.lessonName.value.isNotEmpty 
            ? controller.lessonName.value
            : 'Lesson Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        )),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            // Dispose controller before going back
            Get.delete<LessonDetailController>();
            Get.back();
          },
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => controller.refreshLessonDetails(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading Lesson Details...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshLessonDetails(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.lesson == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_lesson_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Lesson Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The requested lesson could not be found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshLessonDetails(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshLessonDetails,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Section
                _buildVideoSection(controller),
                const SizedBox(height: 16),
                
                // Lesson Info Section
                _buildLessonInfoSection(controller),
                const SizedBox(height: 16),
                
                // Content Section
                _buildContentSection(controller),
                const SizedBox(height: 16),
                
                // Comments Section
                _buildCommentsSection(controller),
                const SizedBox(height: 16),
                
                // Rating Section
                _buildRatingSection(controller),
                const SizedBox(height: 16),
                
                // Debug Section (only in debug mode)
                if (true) // Change to false in production
                  _buildDebugSection(controller),
              ],
            ),
          ),
        );
      }),
      ),
    );
  }

  Widget _buildVideoSection(LessonDetailController controller) {
    final lesson = controller.lesson!;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player Area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  // Player or thumbnail
                  Obx(() {
                    if (controller.isPlayerInitialized.value && controller.chewieController != null) {
                      return Stack(
                        children: [
                          Chewie(controller: controller.chewieController!),
                          // Show preview timer overlay
                          if (controller.previewMode.value)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Preview: ${controller.previewTimeRemaining.value}s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                    
                    // Show enrollment message if not enrolled
                    if (!controller.isEnrolled.value) {
                      return _buildEnrollmentMessage(controller);
                    }
                    
                    // Show video error if any (but not for PENDING status)
                    if (controller.videoError.value.isNotEmpty && 
                        lesson.video.processingStatus.toLowerCase() != 'pending') {
                      return _buildVideoErrorState(controller);
                    }
                    
                    // Show video thumbnail
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                      child: CachedNetworkImage(
                        imageUrl: lesson.image.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Video overlay (only show if not initialized, no error, and enrolled)
                  Obx(() {
                    if (!controller.isPlayerInitialized.value && 
                        controller.videoError.value.isEmpty && 
                        controller.isEnrolled.value) {
                      return Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: controller.onVideoTap,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: controller.isVideoLoading.value
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
          
          // Video Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.lessonName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.video_library,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lesson.video.videoName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.numbers,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sequence: ${lesson.sequenceNumber ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Progress indicator
                Obx(() {
                  if (controller.totalVideoDuration.value > 0) {
                    final progress = controller.currentVideoPosition.value / controller.totalVideoDuration.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Progress: ${controller.currentVideoPosition.value}s / ${controller.totalVideoDuration.value}s',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            if (controller.isCompleted.value)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            controller.isCompleted.value ? Colors.green : Colors.blue,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonInfoSection(LessonDetailController controller) {
    final lesson = controller.lesson!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lesson Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow('Lesson ID', lesson.lessonId.toString()),
          _buildInfoRow('Course ID', lesson.courseId.toString()),
          _buildInfoRow('Sequence', lesson.sequenceNumber?.toString() ?? 'N/A'),
          _buildInfoRow('Video Status', controller.getProcessingStatusText(lesson.video.processingStatus)),
          _buildInfoRow('Comments', '${lesson.comments?.length ?? 0}'),
          
          // Average Rating Display
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _buildAverageRatingDisplay(controller),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageRatingDisplay(LessonDetailController controller) {
    return Obx(() {
      if (controller.isAverageRatingLoading.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading course rating...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      if (controller.averageRatingError.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to load rating: ${controller.averageRatingError.value}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final rating = controller.averageRating.value;
      final totalRatings = controller.totalRating.value;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber[50]!,
              Colors.orange[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Course Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                // Star Rating Display
                Row(
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return Icon(
                      starIndex <= rating
                          ? Icons.star_rounded
                          : starIndex <= rating + 0.5
                              ? Icons.star_half_rounded
                              : Icons.star_border_rounded,
                      size: 24,
                      color: Colors.amber[600],
                    );
                  }),
                ),
                const SizedBox(width: 12),
                
                // Rating Number and Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: controller.getRatingColor(rating),
                      ),
                    ),
                    Text(
                      controller.getRatingText(rating),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Total Ratings Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${totalRatings} ${totalRatings == 1 ? 'rating' : 'ratings'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            // Rating Progress Bar (if there are ratings)
            if (totalRatings > 0) ...[
              const SizedBox(height: 12),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: rating / 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: controller.getRatingColor(rating),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildContentSection(LessonDetailController controller) {
    final lesson = controller.lesson!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lesson Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson.lessonContent,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(LessonDetailController controller) {
    final lesson = controller.lesson!;
    final comments = lesson.comments ?? [];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${comments.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.addComment,
                icon: Icon(
                  Icons.add_comment,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (comments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No comments yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to comment on this lesson',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    comments[index].toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(LessonDetailController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.purple[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.amber[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rate This Lesson',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Obx(() {
                if (controller.isRatingSubmitted.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rated',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 20),
          
          // Star Rating
          Obx(() {
            if (controller.isRatingSubmitted.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thank you for rating this lesson!',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How would you rate this lesson?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Star Rating Widget
                Row(
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () => controller.setRating(starIndex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Obx(() {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              starIndex <= controller.userRating.value
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 40,
                              color: starIndex <= controller.userRating.value
                                  ? Colors.amber[600]
                                  : Colors.grey[400],
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                
                // Rating Text
                Obx(() {
                  if (controller.userRating.value > 0) {
                    String ratingText = '';
                    switch (controller.userRating.value) {
                      case 1:
                        ratingText = 'Poor';
                        break;
                      case 2:
                        ratingText = 'Fair';
                        break;
                      case 3:
                        ratingText = 'Good';
                        break;
                      case 4:
                        ratingText = 'Very Good';
                        break;
                      case 5:
                        ratingText = 'Excellent';
                        break;
                    }
                    return Text(
                      ratingText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 20),
                
                // Comment Section
                const Text(
                  'Share your thoughts (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    onChanged: controller.setComment,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tell us what you think about this lesson...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Error Message
                Obx(() {
                  if (controller.ratingError.value.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.ratingError.value,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                // Submit Button
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isRatingLoading.value
                          ? null
                          : controller.submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: controller.isRatingLoading.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Submitting...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Rating',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVideoErrorState(LessonDetailController controller) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Video Playback Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.videoError.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.retryVideoInitialization(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Show more details or alternative options
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Video Error Details'),
                          content: Text(controller.videoError.value),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Close'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.retryVideoInitialization();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollmentMessage(LessonDetailController controller) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 60,
                color: Colors.blue[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Enrollment Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please enroll in this course to access the full video content',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to course enrollment or course details
                  Get.back(); // Go back to course screen to enroll
                  Get.snackbar(
                    'Enrollment',
                    'Please go back to the course screen to enroll',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                    icon: const Icon(Icons.school, color: Colors.white),
                  );
                },
                icon: const Icon(Icons.school),
                label: const Text('Go to Course'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugSection(LessonDetailController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Debug Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          Obx(() {
            final lesson = controller.lesson;
            if (lesson == null) {
              return const Text('No lesson data available');
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDebugRow('Video ID', lesson.video.videoId.toString()),
                _buildDebugRow('Video Status', lesson.video.processingStatus),
                _buildDebugRow('Range Video URL', controller.getVideoStreamUrl()),
                _buildDebugRow('Is Enrolled', controller.isEnrolled.value.toString()),
                _buildDebugRow('Is Video Ready', controller.isVideoReady.value.toString()),
                _buildDebugRow('Preview Mode', controller.previewMode.value.toString()),
                _buildDebugRow('Player Initialized', controller.isPlayerInitialized.value.toString()),
                _buildDebugRow('Video Loading', controller.isVideoLoading.value.toString()),
                _buildDebugRow('Video Error', controller.videoError.value.isEmpty ? 'None' : controller.videoError.value),
                _buildDebugRow('Retry Count', controller.retryCount.value.toString()),
                _buildDebugRow('Enrollment ID', controller.enrollmentId.value.toString()),
                _buildDebugRow('Last Watched', '${controller.lastWatchedSeconds.value}s'),
                _buildDebugRow('Is Completed', controller.isCompleted.value.toString()),
                _buildDebugRow('Total Duration', '${controller.totalVideoDuration.value}s'),
                _buildDebugRow('User Rating', controller.userRating.value.toString()),
                _buildDebugRow('Rating Submitted', controller.isRatingSubmitted.value.toString()),
                _buildDebugRow('Rating Loading', controller.isRatingLoading.value.toString()),
                _buildDebugRow('Rating Error', controller.ratingError.value.isEmpty ? 'None' : controller.ratingError.value),
                _buildDebugRow('Average Rating', controller.averageRating.value.toStringAsFixed(1)),
                _buildDebugRow('Total Ratings', controller.totalRating.value.toString()),
                _buildDebugRow('Avg Rating Loading', controller.isAverageRatingLoading.value.toString()),
                _buildDebugRow('Avg Rating Error', controller.averageRatingError.value.isEmpty ? 'None' : controller.averageRatingError.value),
              ],
            );
          }),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              ElevatedButton(
                onPressed: () => controller.testVideoUrl(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Test URL', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.testRangeRequest(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Test Range', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.initializeVideoPlayer(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Init Player', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.updateProgressManually(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Update Progress', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.submitRating(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Test Rating', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.fetchAverageRating(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Fetch Avg Rating', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
