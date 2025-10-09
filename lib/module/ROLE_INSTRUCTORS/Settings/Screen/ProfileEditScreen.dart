import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/SettingsControllerInstructor.dart';

class ProfileEditScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingControllerInstructor>(
      init: SettingControllerInstructor(),
      builder: (controller) {
        // Initialize controllers with current values
        nameController.text = controller.UserName;
        emailController.text = controller.userEmail;
        phoneController.text = controller.userPhone;
        bioController.text = controller.userBio;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Profile"),
            actions: [
              Obx(() => TextButton(
                onPressed: controller.isUpdatingProfile.value ? null : () async {
                  await controller.updateProfile(
                    name: nameController.text.trim(),
                    email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                    phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                    bio: bioController.text.trim().isNotEmpty ? bioController.text.trim() : null,
                  );
                },
                child: controller.isUpdatingProfile.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save", style: TextStyle(color: Colors.white)),
              )),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue[100],
                        backgroundImage: controller.profileImage.isNotEmpty
                            ? NetworkImage(controller.profileImage)
                            : null,
                        child: controller.profileImage.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.blue)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {
                              Get.snackbar("Info", "Profile picture upload coming soon");
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildTextField(
                  controller: nameController,
                  label: "Full Name",
                  icon: Icons.person,
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: bioController,
                  label: "Bio",
                  icon: Icons.info,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isUpdatingProfile.value ? null : () async {
                      if (nameController.text.trim().isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Name is required",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      await controller.updateProfile(
                        name: nameController.text.trim(),
                        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                        bio: bioController.text.trim().isNotEmpty ? bioController.text.trim() : null,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isUpdatingProfile.value
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
                              Text("Updating..."),
                            ],
                          )
                        : const Text("Update Profile"),
                  )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (isRequired ? " *" : ""),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
