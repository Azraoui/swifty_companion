class User {
  final int id;
  final String login;
  final String? email;
  final String displayname;
  final String? phone;
  final String? location;
  final int wallet;
  final int correctionPoint;
  final UserImage? image;
  final List<CursusUser> cursusUsers;
  final List<ProjectUser> projectsUsers;
  final List<Campus> campus;

  User({
    required this.id,
    required this.login,
    this.email,
    required this.displayname,
    this.phone,
    this.location,
    required this.wallet,
    required this.correctionPoint,
    this.image,
    required this.cursusUsers,
    required this.projectsUsers,
    required this.campus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      login: json['login'] as String,
      email: json['email'] as String?,
      displayname: json['displayname'] as String? ?? json['login'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      wallet: json['wallet'] as int? ?? 0,
      correctionPoint: json['correction_point'] as int? ?? 0,
      image: json['image'] != null ? UserImage.fromJson(json['image']) : null,
      cursusUsers:
          (json['cursus_users'] as List<dynamic>?)
              ?.map((e) => CursusUser.fromJson(e))
              .toList() ??
          [],
      projectsUsers:
          (json['projects_users'] as List<dynamic>?)
              ?.map((e) => ProjectUser.fromJson(e))
              .toList() ??
          [],
      campus:
          (json['campus'] as List<dynamic>?)
              ?.map((e) => Campus.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Get the main cursus (42cursus, id: 21)
  CursusUser? get mainCursus {
    try {
      return cursusUsers.firstWhere((c) => c.cursusId == 21);
    } catch (_) {
      return cursusUsers.isNotEmpty ? cursusUsers.last : null;
    }
  }

  /// Get current level from main cursus
  double get level => mainCursus?.level ?? 0.0;

  /// Get skills from main cursus
  List<Skill> get skills => mainCursus?.skills ?? [];

  /// Get primary campus name
  String get campusName => campus.isNotEmpty ? campus.first.name : 'Unknown';
}

class UserImage {
  final String? link;
  final ImageVersions? versions;

  UserImage({this.link, this.versions});

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      link: json['link'] as String?,
      versions: json['versions'] != null
          ? ImageVersions.fromJson(json['versions'])
          : null,
    );
  }

  String? get mediumUrl => versions?.medium ?? link;
}

class ImageVersions {
  final String? large;
  final String? medium;
  final String? small;
  final String? micro;

  ImageVersions({this.large, this.medium, this.small, this.micro});

  factory ImageVersions.fromJson(Map<String, dynamic> json) {
    return ImageVersions(
      large: json['large'] as String?,
      medium: json['medium'] as String?,
      small: json['small'] as String?,
      micro: json['micro'] as String?,
    );
  }
}

class CursusUser {
  final int id;
  final double level;
  final String? grade;
  final int cursusId;
  final Cursus? cursus;
  final List<Skill> skills;

  CursusUser({
    required this.id,
    required this.level,
    this.grade,
    required this.cursusId,
    this.cursus,
    required this.skills,
  });

  factory CursusUser.fromJson(Map<String, dynamic> json) {
    return CursusUser(
      id: json['id'] as int,
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
      grade: json['grade'] as String?,
      cursusId: json['cursus_id'] as int,
      cursus: json['cursus'] != null ? Cursus.fromJson(json['cursus']) : null,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => Skill.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Cursus {
  final int id;
  final String name;
  final String slug;

  Cursus({required this.id, required this.name, required this.slug});

  factory Cursus.fromJson(Map<String, dynamic> json) {
    return Cursus(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

class Skill {
  final int id;
  final String name;
  final double level;

  Skill({required this.id, required this.name, required this.level});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as int,
      name: json['name'] as String,
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Get percentage (max level is ~20)
  double get percentage => (level / 20.0 * 100).clamp(0.0, 100.0);
}

class ProjectUser {
  final int id;
  final int? finalMark;
  final String status;
  final bool validated;
  final Project project;

  ProjectUser({
    required this.id,
    this.finalMark,
    required this.status,
    required this.validated,
    required this.project,
  });

  factory ProjectUser.fromJson(Map<String, dynamic> json) {
    return ProjectUser(
      id: json['id'] as int,
      finalMark: json['final_mark'] as int?,
      status: json['status'] as String? ?? 'unknown',
      validated: json['validated?'] as bool? ?? false,
      project: Project.fromJson(json['project']),
    );
  }

  bool get isCompleted => status == 'finished';
  bool get isPassed => validated && finalMark != null && finalMark! >= 0;
}

class Project {
  final int id;
  final String name;
  final String slug;

  Project({required this.id, required this.name, required this.slug});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

class Campus {
  final int id;
  final String name;

  Campus({required this.id, required this.name});

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(id: json['id'] as int, name: json['name'] as String);
  }
}
