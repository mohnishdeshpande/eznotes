class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateException implements CloudStorageException {}

class CouldNotReadException implements CloudStorageException {}

class CouldNotUpdateException implements CloudStorageException {}

class CouldNotDeleteException implements CloudStorageException {}
