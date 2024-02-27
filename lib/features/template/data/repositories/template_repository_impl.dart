import 'package:dartz/dartz.dart';
import 'package:provider_template/core/connection/network_info.dart';
import 'package:provider_template/core/errors/exception.dart';
import 'package:provider_template/core/errors/failure.dart';
import 'package:provider_template/core/params/params.dart';
import 'package:provider_template/features/template/business/entities/template_entity.dart';
import 'package:provider_template/features/template/business/repositories/template_repository.dart';
import 'package:provider_template/features/template/data/datasources/template_local_data_source.dart';
import 'package:provider_template/features/template/data/datasources/template_remote_data_source.dart';
import 'package:provider_template/features/template/data/models/template_model.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateRemoteDataSource remoteDataSource;
  final TemplateLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TemplateRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TemplateEntity>> getTemplate(
      {required TemplateParams templateParams}) async {
    if (await networkInfo.isConnected != null) {
      if (await networkInfo.isConnected!) {
        try {
          TemplateModel remoteTemplate = await remoteDataSource.getTemplate(
              templateParams: templateParams);
          localDataSource.cacheTemplate(templateToCache: remoteTemplate);
          return Right(remoteTemplate);
        } on ServerException {
          return Left(ServerFailure());
        }
      } else {
        try {
          TemplateModel localTemplate = await localDataSource.getLastTemplate();
          return Right(localTemplate);
        } on CacheException {
          return Left(CacheFailure());
        }
      }
    } else {
      return Left(NullPointerFailure());
    }
  }
}
