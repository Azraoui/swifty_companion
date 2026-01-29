import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/skill_bar.dart';
import '../widgets/project_tile.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with profile image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                user.displayname,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (user.image?.mediumUrl != null)
                    Image.network(
                      user.image!.mediumUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  else
                    _buildPlaceholderImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  _buildInfoCard(context),
                  const SizedBox(height: 24),

                  // Level Progress
                  _buildLevelSection(context),
                  const SizedBox(height: 24),

                  // Skills Section
                  if (user.skills.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Skills'),
                    const SizedBox(height: 8),
                    _buildSkillsSection(),
                    const SizedBox(height: 24),
                  ],

                  // Projects Section
                  _buildSectionTitle(context, 'Projects'),
                  const SizedBox(height: 8),
                  _buildProjectsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 80, color: Colors.grey),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.person, 'Login', user.login),
            const Divider(),
            if (user.email != null) ...[
              _buildInfoRow(Icons.email, 'Email', user.email!),
              const Divider(),
            ],
            _buildInfoRow(
              Icons.location_on,
              'Location',
              user.location ?? 'Not available',
            ),
            const Divider(),
            _buildInfoRow(Icons.business, 'Campus', user.campusName),
            const Divider(),
            _buildInfoRow(
              Icons.account_balance_wallet,
              'Wallet',
              '${user.wallet} ₳',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.star,
              'Evaluation Points',
              '${user.correctionPoint}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSection(BuildContext context) {
    final level = user.level;
    final levelInt = level.floor();
    final progress = level - levelInt;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Level $levelInt',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% to next level',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: user.skills
              .map(
                (skill) => SkillBar(
                  name: skill.name,
                  level: skill.level,
                  percentage: skill.percentage,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    final projects = user.projectsUsers;

    if (projects.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No projects yet')),
        ),
      );
    }

    // Sort: completed first, then by final mark
    final sortedProjects = List<ProjectUser>.from(projects)
      ..sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return -1;
        if (!a.isCompleted && b.isCompleted) return 1;
        return (b.finalMark ?? 0).compareTo(a.finalMark ?? 0);
      });

    return Column(
      children: sortedProjects.map((p) => ProjectTile(projectUser: p)).toList(),
    );
  }
}
