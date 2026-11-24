import 'package:get/get.dart';
import 'package:rental_project/core/locale/app_translation.dart';

/// Merges AppTranslation (your existing keys) with the extra keys below,
/// so app_translation.dart does not need to be edited.
class MergedTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    final base = AppTranslation().keys;
    final out = <String, Map<String, String>>{};
    for (final l in {...base.keys, ...ExtraTranslation.keys.keys}) {
      out[l] = {...?base[l], ...?ExtraTranslation.keys[l]};
    }
    return out;
  }
}

class ExtraTranslation {
  static const Map<String, Map<String, String>> keys = {
    'ar_SA': {
      'save_error': 'تعذّر الحفظ، حاول مرة أخرى',
      'confirm': 'تأكيد',
      'close': 'إغلاق',
      'edit': 'تعديل',
      'delete': 'حذف',
      'all': 'الكل',
      'reason_required': 'اكتب السبب أولاً',
      // units
      'search_units': 'ابحث باسم الوحدة',
      'edit_unit': 'تعديل الوحدة',
      'delete_unit_confirm': 'حذف هذه الوحدة؟',
      'unit_has_history': 'لا يمكن حذف وحدة لها عقود سابقة أو حالية',
      // tenants
      'search_tenants': 'ابحث بالاسم أو الجوال',
      'national_id': 'رقم الهوية (اختياري)',
      'edit_tenant': 'تعديل المستأجر',
      'delete_tenant_confirm': 'حذف هذا المستأجر؟',
      'tenant_has_history': 'لا يمكن حذف مستأجر له عقود أو دفعات',
      'filter_has_debt': 'عليهم مبالغ',
      // contracts
      'search_contracts': 'ابحث بالوحدة أو المستأجر',
      'filter_active': 'سارية',
      'filter_ended': 'منتهية',
      'start_date': 'تاريخ البداية',
      'ends': 'ينتهي',
      'days_left': 'متبقي @n يوم',
      'cs_active': 'ساري',
      'cs_terminated': 'مفسوخ',
      'cs_expired': 'منتهي المدة',
      'cs_ended': 'انتهت مدته',
      'terminate_contract': 'إنهاء العقد',
      'termination_reason': 'سبب الإنهاء',
      'terminate_confirm': 'سيتم إنهاء العقد وإلغاء الاستحقاقات القادمة غير المسددة. متابعة؟',
      'renew_contract': 'تجديد العقد',
      // finance
      'search_dues': 'ابحث بالمستأجر',
      'filter_overdue': 'متأخرة',
      'filter_open': 'مفتوحة',
      'filter_paid': 'مسددة',
      'allocations': 'التخصيصات',
      'no_allocations': 'لا توجد تخصيصات',
      'reverse_confirm': 'إلغاء هذا التخصيص؟ سيعود المبلغ رصيداً غير مخصّص على الدفعة.',
      'void_payment': 'إلغاء الدفعة',
      'void_reason': 'سبب الإلغاء',
      'voided': 'ملغاة',
      // dashboard
      'dashboard': 'الرئيسية',
      'overdue_total': 'إجمالي المتأخرات',
      'overdue_count': 'استحقاق متأخر',
      'collected_month': 'المقبوض هذا الشهر',
      'due_next_7': 'مستحق خلال 7 أيام',
      'occupancy': 'نسبة الإشغال',
      'expiring_contracts': 'عقود تنتهي خلال 90 يوم',
      'top_debtors': 'أعلى المتأخرين',
      'nothing_here': 'لا يوجد شي هنا',
      'quick_actions': 'عمليات سريعة',
      'qa_payment': 'تسجيل دفعة',
      'qa_contract': 'عقد جديد',
      'qa_tenant': 'مستأجر جديد',
      'qa_unit': 'وحدة جديدة',
      'recent_payments': 'آخر الدفعات',
    },
    'en_US': {
      'save_error': 'Could not save. Please try again.',
      'confirm': 'Confirm',
      'close': 'Close',
      'edit': 'Edit',
      'delete': 'Delete',
      'all': 'All',
      'reason_required': 'Please enter a reason',
      // units
      'search_units': 'Search by unit name',
      'edit_unit': 'Edit unit',
      'delete_unit_confirm': 'Delete this unit?',
      'unit_has_history': 'Cannot delete a unit that has past or current contracts',
      // tenants
      'search_tenants': 'Search by name or phone',
      'national_id': 'National ID (optional)',
      'edit_tenant': 'Edit tenant',
      'delete_tenant_confirm': 'Delete this tenant?',
      'tenant_has_history': 'Cannot delete a tenant who has contracts or payments',
      'filter_has_debt': 'Owing',
      // contracts
      'search_contracts': 'Search by unit or tenant',
      'filter_active': 'Active',
      'filter_ended': 'Ended',
      'start_date': 'Start date',
      'ends': 'Ends',
      'days_left': '@n days left',
      'cs_active': 'Active',
      'cs_terminated': 'Terminated',
      'cs_expired': 'Expired',
      'cs_ended': 'Term ended',
      'terminate_contract': 'Terminate contract',
      'termination_reason': 'Termination reason',
      'terminate_confirm':
          'The contract will be ended and upcoming unpaid dues will be cancelled. Continue?',
      'renew_contract': 'Renew contract',
      // finance
      'search_dues': 'Search by tenant',
      'filter_overdue': 'Overdue',
      'filter_open': 'Open',
      'filter_paid': 'Paid',
      'allocations': 'Allocations',
      'no_allocations': 'No allocations',
      'reverse_confirm':
          'Reverse this allocation? The amount returns as unallocated credit on the payment.',
      'void_payment': 'Void payment',
      'void_reason': 'Void reason',
      'voided': 'Voided',
      // dashboard
      'dashboard': 'Dashboard',
      'overdue_total': 'Total overdue',
      'overdue_count': 'overdue dues',
      'collected_month': 'Collected this month',
      'due_next_7': 'Due in 7 days',
      'occupancy': 'Occupancy',
      'expiring_contracts': 'Contracts ending within 90 days',
      'top_debtors': 'Top overdue tenants',
      'nothing_here': 'Nothing here',
      'quick_actions': 'Quick actions',
      'qa_payment': 'Record payment',
      'qa_contract': 'New contract',
      'qa_tenant': 'New tenant',
      'qa_unit': 'New unit',
      'recent_payments': 'Recent payments',
    },
  };
}
