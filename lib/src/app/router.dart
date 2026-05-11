import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'navigation_keys.dart';
import 'routing/app_route_policy.dart';
import '../features/auth/doctor/presentation/doctor_login_screen.dart';
import '../features/animals/presentation/animal_list_screen.dart';
import '../features/auth/login_entry_screen.dart';
import '../features/auth/technician/presentation/technician_login_screen.dart';
import '../features/home/doctor/presentation/doctor_home_screen.dart';
import '../features/home/home_shell_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/providers/presentation/doctor_detail_screen.dart';
import '../features/providers/presentation/doctor_list_screen.dart';
import '../features/providers/presentation/technician_detail_screen.dart';
import '../features/providers/presentation/technician_list_screen.dart';
import '../features/service_requests/presentation/booking_wizard_screen.dart';
import '../features/service_requests/presentation/service_requests_tab_screen.dart'
    show ServiceRequestDetailScreen;
import '../features/livestock_booking/presentation/booking_history_screen.dart';
import '../features/livestock_booking/presentation/professional_livestock_request_management_screen.dart';
import '../features/professional_finance/presentation/professional_transaction_history_screen.dart';
import '../features/professional_finance/presentation/professional_wallet_earnings_screen.dart';
import '../features/enterprise_insights/presentation/professional_insights_hub_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/knowledge_hub/presentation/knowledge_categories_screen.dart';
import '../features/knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import '../features/knowledge_hub/presentation/knowledge_post_detail_screen.dart';
import '../features/knowledge_hub/presentation/knowledge_post_list_screen.dart';
import '../features/notifications/presentation/notification_preferences_screen.dart';
import '../features/notifications/presentation/notifications_list_screen.dart';
import '../features/profile/presentation/about_screen.dart';
import '../features/profile/presentation/app_settings_screen.dart';
import '../features/profile/presentation/area_setting_screen.dart';
import '../features/profile/presentation/edit_profile_account_screen.dart';
import '../features/profile/presentation/edit_profile_basic_screen.dart';
import '../features/profile/presentation/edit_profile_contact_screen.dart';
import '../features/profile/presentation/edit_profile_documents_screen.dart';
import '../features/profile/presentation/edit_profile_location_screen.dart';
import '../features/profile/presentation/edit_profile_photos_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/professional_profile/domain/professional_persona.dart';
import '../features/professional_profile/domain/professional_profile_section.dart';
import '../features/professional_profile/presentation/professional_profile_hub_screen.dart';
import '../features/professional_profile/presentation/professional_profile_section_editor_screen.dart';
import '../features/professional_verification/presentation/professional_verification_workflow_screen.dart';
import '../features/profile/presentation/help_support_screen.dart';
import '../features/ai_technician_application/data/ai_technician_models.dart';
import '../features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_service_area_selection_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_intro_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_request_complete_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_request_detail_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_requests_list_screen.dart';
import '../features/ai_technician_application/presentation/ai_semen_from_template_confirm_screen.dart';
import '../features/ai_technician_application/presentation/ai_semen_inventory_screen.dart';
import '../features/ai_technician_application/presentation/ai_semen_template_catalog_screen.dart';
import '../features/ai_technician_application/presentation/ai_semen_template_detail_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_service_form_screen.dart';
import '../features/ai_technician_application/presentation/ai_technician_services_list_screen.dart';
import '../features/ai_farmer_services/presentation/ai_digital_service_record_view_screen.dart';
import '../features/ai_farmer_services/presentation/ai_farmer_my_request_detail_screen.dart';
import '../features/ai_farmer_services/presentation/ai_farmer_request_complaint_screen.dart';
import '../features/ai_farmer_services/presentation/ai_farmer_request_review_screen.dart';
import '../features/ai_farmer_services/presentation/ai_my_requests_screen.dart';
import '../features/ai_farmer_services/presentation/ai_service_request_form_screen.dart';
import '../features/ai_farmer_services/presentation/ai_technician_finder_screen.dart';
import '../features/ai_farmer_services/presentation/ai_technician_public_profile_screen.dart';
import '../features/session/application/session_notifier.dart';
import '../features/workspace/application/available_workspaces_provider.dart';
import '../features/workspace/application/workspace_surface_provider.dart';
import '../features/workspace/presentation/professional_workspace_shell_screen.dart';
import '../features/session/presentation/admin_gateway_screen.dart';
import '../features/session/presentation/session_forbidden_screen.dart';
import '../features/session/presentation/workspace_gate_screen.dart';
import '../features/technician_ai/presentation/technician_ai_record_form_screen.dart';
import '../features/technician_ai/presentation/technician_complete_job_screen.dart';
import '../features/technician_ai/presentation/technician_dashboard_screen.dart';
import '../features/technician_ai/presentation/technician_job_detail_screen.dart';
import '../features/technician_ai/presentation/technician_jobs_screen.dart';
import '../features/technician_ai/presentation/technician_requests_screen.dart';

bool _isPublicCustomerPath(String path) {
  return path == SplashScreen.routePath ||
      path == OnboardingScreen.routePath ||
      path == LoginEntryScreen.routePath;
}

/// Routes browsable without customer OTP (guest / marketing).
bool _isGuestAccessibleCustomerRoute(String path) {
  if (path == HomeShellScreen.routePath) return true;
  if (path.startsWith('/providers/')) return true;
  if (path.startsWith('/knowledge')) return true;
  // AI technician finder + public profiles only (`/ai-services/request*` stays protected).
  if (path.startsWith('/ai-services/technicians')) return true;
  if (path == HelpSupportScreen.routePath || path == AboutScreen.routePath) {
    return true;
  }
  if (path == AiTechnicianApplicationEntryScreen.routePath) return true;
  return false;
}

bool _hasWorkspaceAccess(Ref ref, SessionState auth, String path) {
  final asyncEntries = ref.read(availableWorkspacesProvider);
  final entryAccess = asyncEntries.maybeWhen(
    data: (entries) =>
        entries.any((entry) => path.startsWith(entry.routePath)),
    orElse: () => false,
  );
  if (entryAccess) return true;

  switch (auth.role) {
    case AppRole.aiTechnician:
      return path.startsWith(ProfessionalWorkspaceShellScreen.technicianPath) ||
          path.startsWith(
            ProfessionalWorkspaceShellScreen.aiTechnicianLegacyPath,
          );
    case AppRole.doctor:
      return path.startsWith(ProfessionalWorkspaceShellScreen.doctorPath);
    case AppRole.admin:
    case AppRole.technician:
      return true;
    case AppRole.customer:
    case null:
      return false;
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionNotifierProvider, (_, _) => refresh.value++);
  ref.listen(workspaceSurfaceProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: pdRootNavigatorKey,
    initialLocation: SplashScreen.routePath,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.uri.path;
      final auth = ref.read(sessionNotifierProvider);

      if (loc == '/tutorials') {
        return KnowledgePostListScreen.routePath;
      }
      if (loc.startsWith('/tutorials/')) {
        final tail = loc.substring('/tutorials/'.length);
        if (tail.isEmpty) return KnowledgePostListScreen.routePath;
        return '${KnowledgePostListScreen.routePath}/$tail';
      }

      if (loc == LoginEntryScreen.routePath && auth.isAuthenticated) {
        return defaultLocationForSession(auth);
      }

      final workspaceRedirect = redirectForWorkspacePolicy(
        location: loc,
        auth: auth,
      );
      if (workspaceRedirect != null) return workspaceRedirect;

      if (_isPublicCustomerPath(loc)) return null;
      if (loc.startsWith('/workspace/')) {
        if (!(auth.isAuthenticated || auth.professionalShellActive)) {
          return LoginEntryScreen.routePath;
        }
        if (!_hasWorkspaceAccess(ref, auth, loc)) {
          return SessionForbiddenScreen.routePath;
        }
        return null;
      }
      if (loc.startsWith('/doctor')) return null;
      if (loc.startsWith('/technician')) return null;
      if (_isGuestAccessibleCustomerRoute(loc)) return null;
      if (!auth.isAuthenticated) return LoginEntryScreen.routePath;
      return null;
    },
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: OnboardingScreen.routePath,
        name: OnboardingScreen.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: LoginEntryScreen.routePath,
        name: LoginEntryScreen.routeName,
        builder: (context, state) => const LoginEntryScreen(),
      ),
      GoRoute(
        path: WorkspaceGateScreen.routePath,
        name: WorkspaceGateScreen.routeName,
        builder: (context, state) => const WorkspaceGateScreen(),
      ),
      GoRoute(
        path: SessionForbiddenScreen.routePath,
        name: SessionForbiddenScreen.routeName,
        builder: (context, state) => const SessionForbiddenScreen(),
      ),
      GoRoute(
        path: AdminGatewayScreen.routePath,
        name: AdminGatewayScreen.routeName,
        builder: (context, state) => const AdminGatewayScreen(),
      ),
      GoRoute(
        path: HomeShellScreen.routePath,
        name: HomeShellScreen.routeName,
        builder: (context, state) => const HomeShellScreen(),
      ),
      GoRoute(
        path: ProfessionalWorkspaceShellScreen.technicianPath,
        name: ProfessionalWorkspaceShellScreen.aiTechnicianRouteName,
        builder: (context, state) => const ProfessionalWorkspaceShellScreen(
          workspaceRole: AppRole.aiTechnician,
        ),
      ),
      GoRoute(
        path: ProfessionalWorkspaceShellScreen.aiTechnicianLegacyPath,
        name: ProfessionalWorkspaceShellScreen.aiTechnicianLegacyRouteName,
        builder: (context, state) => const ProfessionalWorkspaceShellScreen(
          workspaceRole: AppRole.aiTechnician,
        ),
      ),
      GoRoute(
        path: ProfessionalWorkspaceShellScreen.doctorPath,
        name: ProfessionalWorkspaceShellScreen.doctorRouteName,
        builder: (context, state) => const ProfessionalWorkspaceShellScreen(
          workspaceRole: AppRole.doctor,
        ),
      ),
      GoRoute(
        path: ProfessionalWalletEarningsScreen.routePath,
        name: 'professionalWalletEarnings',
        builder: (context, state) => const ProfessionalWalletEarningsScreen(),
      ),
      GoRoute(
        path: ProfessionalInsightsHubScreen.routePath,
        name: ProfessionalInsightsHubScreen.routeName,
        builder: (context, state) => const ProfessionalInsightsHubScreen(),
      ),
      GoRoute(
        path: ProfessionalTransactionHistoryScreen.routePath,
        name: 'professionalTransactionHistory',
        builder: (context, state) =>
            const ProfessionalTransactionHistoryScreen(),
      ),
      GoRoute(
        path: DoctorLoginScreen.routePath,
        name: DoctorLoginScreen.routeName,
        builder: (context, state) => const DoctorLoginScreen(),
      ),
      GoRoute(
        path: TechnicianLoginScreen.routePath,
        name: TechnicianLoginScreen.routeName,
        builder: (context, state) => const TechnicianLoginScreen(),
      ),
      GoRoute(
        path: TechnicianDashboardScreen.routePath,
        name: TechnicianDashboardScreen.routeName,
        builder: (context, state) => const TechnicianDashboardScreen(),
      ),
      GoRoute(
        path: TechnicianRequestsScreen.routePath,
        name: TechnicianRequestsScreen.routeName,
        builder: (context, state) => const TechnicianRequestsScreen(),
      ),
      GoRoute(
        path: TechnicianJobsScreen.routePath,
        name: TechnicianJobsScreen.routeName,
        builder: (context, state) => const TechnicianJobsScreen(),
      ),
      GoRoute(
        path: '/technician/jobs/:jobId',
        name: TechnicianJobDetailScreen.routeName,
        builder: (context, state) {
          final id = state.pathParameters['jobId']!;
          return TechnicianJobDetailScreen(jobId: id);
        },
        routes: [
          GoRoute(
            path: 'record',
            name: 'technicianAiRecord',
            builder: (context, state) {
              final id = state.pathParameters['jobId']!;
              return TechnicianAiRecordFormScreen(jobId: id);
            },
          ),
          GoRoute(
            path: 'complete',
            name: 'technicianCompleteJob',
            builder: (context, state) {
              final id = state.pathParameters['jobId']!;
              return TechnicianCompleteJobScreen(jobId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: DoctorHomeScreen.routePath,
        name: DoctorHomeScreen.routeName,
        builder: (context, state) => const DoctorHomeScreen(),
      ),
      GoRoute(
        path: DoctorListScreen.routePath,
        name: DoctorListScreen.routeName,
        builder: (context, state) => const DoctorListScreen(),
        routes: [
          GoRoute(
            path: ':doctorId',
            name: DoctorDetailScreen.routeName,
            builder: (context, state) {
              final id = state.pathParameters['doctorId']!;
              return DoctorDetailScreen(doctorId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: TechnicianListScreen.routePath,
        name: TechnicianListScreen.routeName,
        builder: (context, state) => const TechnicianListScreen(),
        routes: [
          GoRoute(
            path: ':technicianId',
            name: TechnicianDetailScreen.routeName,
            builder: (context, state) {
              final id = state.pathParameters['technicianId']!;
              return TechnicianDetailScreen(technicianId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: NotificationsListScreen.routePath,
        name: NotificationsListScreen.routeName,
        builder: (context, state) => const NotificationsListScreen(),
        routes: [
          GoRoute(
            path: NotificationPreferencesScreen.routePath,
            name: NotificationPreferencesScreen.routeName,
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: EditProfileScreen.routePath,
        name: EditProfileScreen.routeName,
        builder: (context, state) => const EditProfileScreen(),
        routes: [
          GoRoute(
            path: 'photos',
            name: EditProfilePhotosScreen.routeName,
            builder: (context, state) => const EditProfilePhotosScreen(),
          ),
          GoRoute(
            path: 'basic',
            name: EditProfileBasicScreen.routeName,
            builder: (context, state) => const EditProfileBasicScreen(),
          ),
          GoRoute(
            path: 'contact',
            name: EditProfileContactScreen.routeName,
            builder: (context, state) => const EditProfileContactScreen(),
          ),
          GoRoute(
            path: 'location',
            name: EditProfileLocationScreen.routeName,
            builder: (context, state) => const EditProfileLocationScreen(),
          ),
          GoRoute(
            path: 'documents',
            name: EditProfileDocumentsScreen.routeName,
            builder: (context, state) => const EditProfileDocumentsScreen(),
          ),
          GoRoute(
            path: 'account',
            name: EditProfileAccountScreen.routeName,
            builder: (context, state) => const EditProfileAccountScreen(),
          ),
        ],
      ),
      GoRoute(
        path: ProfessionalProfileHubScreen.routePath,
        name: 'professionalProfileHub',
        builder: (context, state) {
          final persona = parseProfessionalPersonaRoute(
            state.pathParameters['persona'],
          );
          if (persona == null) {
            return const Scaffold(
              body: Center(child: Text('প্রোফাইল রাউট সঠিক নয়')),
            );
          }
          return ProfessionalProfileHubScreen(persona: persona);
        },
        routes: [
          GoRoute(
            path: 'section/:section',
            name: 'professionalProfileSection',
            builder: (context, state) {
              final persona = parseProfessionalPersonaRoute(
                state.pathParameters['persona'],
              );
              final section = parseProfessionalProfileSection(
                state.pathParameters['section'],
              );
              if (persona == null || section == null) {
                return const Scaffold(
                  body: Center(child: Text('প্রোফাইল রাউট সঠিক নয়')),
                );
              }
              return ProfessionalProfileSectionEditorScreen(
                persona: persona,
                section: section,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: ProfessionalVerificationWorkflowScreen.routePath,
        name: 'professionalVerificationWorkflow',
        builder: (context, state) {
          final persona = parseProfessionalPersonaRoute(
            state.pathParameters['persona'],
          );
          if (persona == null) {
            return const Scaffold(
              body: Center(child: Text('রাউট সঠিক নয়')),
            );
          }
          return ProfessionalVerificationWorkflowScreen(persona: persona);
        },
      ),
      GoRoute(
        path: AiTechnicianApplicationEntryScreen.routePath,
        name: AiTechnicianApplicationEntryScreen.routeName,
        builder: (context, state) => const AiTechnicianApplicationEntryScreen(),
      ),
      GoRoute(
        path: AiTechnicianIntroScreen.routePath,
        name: AiTechnicianIntroScreen.routeName,
        builder: (context, state) => const AiTechnicianIntroScreen(),
      ),
      GoRoute(
        path: AiTechnicianApplicationFormScreen.routePath,
        name: AiTechnicianApplicationFormScreen.routeName,
        builder: (context, state) => AiTechnicianApplicationFormScreen(
          initialStep: state.extra is int ? state.extra as int : null,
        ),
      ),
      GoRoute(
        path: AiTechnicianServiceAreaSelectionScreen.routePath,
        name: AiTechnicianServiceAreaSelectionScreen.routeName,
        builder: (context, state) {
          final extra = state.extra;
          List<AiTechnicianDivisionArea>? initial;
          if (extra is List<AiTechnicianDivisionArea>) {
            initial = List<AiTechnicianDivisionArea>.from(extra);
          }
          return AiTechnicianServiceAreaSelectionScreen(initialAreas: initial);
        },
      ),
      GoRoute(
        path: AiTechnicianApplicationStatusScreen.routePath,
        name: AiTechnicianApplicationStatusScreen.routeName,
        builder: (context, state) =>
            const AiTechnicianApplicationStatusScreen(),
      ),
      GoRoute(
        path: AiTechnicianDashboardScreen.routePath,
        name: AiTechnicianDashboardScreen.routeName,
        builder: (context, state) => const AiTechnicianDashboardScreen(),
      ),
      GoRoute(
        path: AiTechnicianRequestsListScreen.routePath,
        name: AiTechnicianRequestsListScreen.routeName,
        builder: (context, state) => const AiTechnicianRequestsListScreen(),
        routes: [
          GoRoute(
            path: ':requestId',
            builder: (context, state) {
              final id = state.pathParameters['requestId']!;
              return AiTechnicianRequestDetailScreen(requestId: id);
            },
            routes: [
              GoRoute(
                path: 'complete',
                builder: (context, state) {
                  final id = state.pathParameters['requestId']!;
                  return AiTechnicianRequestCompleteScreen(requestId: id);
                },
              ),
              GoRoute(
                path: 'record',
                builder: (context, state) {
                  final id = state.pathParameters['requestId']!;
                  return AiDigitalServiceRecordViewScreen(requestId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AiTechnicianServicesListScreen.routePath,
        name: AiTechnicianServicesListScreen.routeName,
        builder: (context, state) => const AiTechnicianServicesListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: AiTechnicianServiceFormScreen.routeNameNew,
            builder: (context, state) => const AiTechnicianServiceFormScreen(),
          ),
          GoRoute(
            path: ':serviceId/edit',
            name: AiTechnicianServiceFormScreen.routeNameEdit,
            builder: (context, state) {
              final id = state.pathParameters['serviceId']!;
              return AiTechnicianServiceFormScreen(serviceId: id);
            },
          ),
          GoRoute(
            path: ':serviceId/semen-inventory',
            builder: (context, state) {
              final id = state.pathParameters['serviceId']!;
              return AiSemenInventoryScreen(serviceId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AiSemenTemplateCatalogScreen.routePath,
        name: AiSemenTemplateCatalogScreen.routeName,
        builder: (context, state) => const AiSemenTemplateCatalogScreen(),
        routes: [
          GoRoute(
            path: ':templateId',
            builder: (context, state) {
              final id = state.pathParameters['templateId']!;
              return AiSemenTemplateDetailScreen(templateId: id);
            },
            routes: [
              GoRoute(
                path: 'confirm',
                builder: (context, state) {
                  final id = state.pathParameters['templateId']!;
                  return AiSemenFromTemplateConfirmScreen(templateId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AiTechnicianFinderScreen.routePath,
        name: AiTechnicianFinderScreen.routeName,
        builder: (context, state) => const AiTechnicianFinderScreen(),
        routes: [
          GoRoute(
            path: ':technicianId',
            name: AiTechnicianPublicProfileScreen.routeName,
            builder: (context, state) {
              final id = state.pathParameters['technicianId']!;
              return AiTechnicianPublicProfileScreen(technicianId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AiServiceRequestFormScreen.routePath,
        name: AiServiceRequestFormScreen.routeName,
        builder: (context, state) => const AiServiceRequestFormScreen(),
      ),
      GoRoute(
        path: AiMyServiceRequestsScreen.routePath,
        name: AiMyServiceRequestsScreen.routeName,
        builder: (context, state) => const AiMyServiceRequestsScreen(),
        routes: [
          GoRoute(
            path: ':requestId',
            builder: (context, state) {
              final id = state.pathParameters['requestId']!;
              return AiFarmerMyRequestDetailScreen(requestId: id);
            },
            routes: [
              GoRoute(
                path: 'record',
                builder: (context, state) {
                  final id = state.pathParameters['requestId']!;
                  return AiDigitalServiceRecordViewScreen(requestId: id);
                },
              ),
              GoRoute(
                path: 'review',
                builder: (context, state) {
                  final id = state.pathParameters['requestId']!;
                  return AiFarmerRequestReviewScreen(requestId: id);
                },
              ),
              GoRoute(
                path: 'complaint',
                builder: (context, state) {
                  final id = state.pathParameters['requestId']!;
                  return AiFarmerRequestComplaintScreen(requestId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AreaSettingScreen.routePath,
        name: AreaSettingScreen.routeName,
        builder: (context, state) => const AreaSettingScreen(),
      ),
      GoRoute(
        path: AppSettingsScreen.routePath,
        name: AppSettingsScreen.routeName,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: HelpSupportScreen.routePath,
        name: HelpSupportScreen.routeName,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AboutScreen.routePath,
        name: AboutScreen.routeName,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AnimalListScreen.routePath,
        name: AnimalListScreen.routeName,
        builder: (context, state) => const AnimalListScreen(),
      ),
      GoRoute(
        path: KnowledgeHubHomeScreen.routePath,
        name: KnowledgeHubHomeScreen.routeName,
        builder: (context, state) => const KnowledgeHubHomeScreen(),
        routes: [
          GoRoute(
            path: 'categories',
            name: KnowledgeCategoriesScreen.routeName,
            builder: (context, state) => const KnowledgeCategoriesScreen(),
          ),
          GoRoute(
            path: 'posts',
            name: KnowledgePostListScreen.routeName,
            builder: (context, state) => const KnowledgePostListScreen(),
            routes: [
              GoRoute(
                path: ':slugOrId',
                name: KnowledgePostDetailScreen.routeName,
                builder: (context, state) {
                  final raw = state.pathParameters['slugOrId']!;
                  return KnowledgePostDetailScreen(slugOrId: raw);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: BookingWizardScreen.routePath,
        name: BookingWizardScreen.routeName,
        builder: (context, state) => const BookingWizardScreen(),
      ),
      GoRoute(
        path: BookingHistoryScreen.routePath,
        name: BookingHistoryScreen.routeName,
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: ProfessionalLivestockRequestManagementScreen.routePath,
        name: ProfessionalLivestockRequestManagementScreen.routeName,
        builder: (context, state) =>
            const ProfessionalLivestockRequestManagementScreen(),
      ),
      GoRoute(
        path: '/service-requests/:requestId',
        name: ServiceRequestDetailScreen.routeName,
        builder: (context, state) {
          final id = state.pathParameters['requestId']!;
          return ServiceRequestDetailScreen(requestId: id);
        },
      ),
    ],
  );
});
