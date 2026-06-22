part of 'report_cubit.dart';

sealed class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial({required this.filter});
  final ReportFilter filter;
}

class ReportLoading extends ReportState {
  const ReportLoading({required this.filter});
  final ReportFilter filter;
}

class ReportLoaded extends ReportState {
  const ReportLoaded({required this.data});
  final ReportData data;
}

class ReportExporting extends ReportState {
  const ReportExporting({this.data});
  final ReportData? data;
}

class ReportError extends ReportState {
  const ReportError({required this.message, required this.filter});
  final String message;
  final ReportFilter filter;
}