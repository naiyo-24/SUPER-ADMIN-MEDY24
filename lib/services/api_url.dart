class ApiUrls {
  static const String baseUrl =
      'http://127.0.0.1:8000/'; // Standardized with trailing slash

  // Patho Lab Auth Endpoints
  static const String pathoLabSignup = 'auth/patho-lab/signup';
  static const String pathoLabLogin = 'auth/patho-lab/login';
  static const String pathoLabGetAll = 'auth/patho-lab/get-all';
  static const String pathoLabGetById = 'auth/patho-lab/get-by';
  static const String pathoLabUpdateById = 'auth/patho-lab/update-by';

  // Core Lab Test Endpoints
  static const String coreTestCreate = 'core-tests/create';
  static const String coreTestGetAll = 'core-tests/get-all';
  static const String coreTestGetById = 'core-tests/get-by';
  static const String coreTestUpdateById = 'core-tests/update-by';
  static const String coreTestDeleteByIds = 'core-tests/delete-by-ids';

  // About Us Endpoints
  static const String aboutUsCreate = 'about-us/create';
  static const String aboutUsGetAll = 'about-us/get-all';
  static const String aboutUsGetById = 'about-us/get-by';
  static const String aboutUsUpdateById = 'about-us/update-by';
  static const String aboutUsDeleteById = 'about-us/delete-by';

  // Medicine Endpoints
  static const String medicineCreate = 'medicines/create';
  static const String medicineGetAll = 'medicines/get-all';
  static const String medicineSearch = 'medicines/search';
  static const String medicineGetById = 'medicines/get-by';
  static const String medicineUpdateById = 'medicines/update-by';
  static const String medicineDeleteByIds = 'medicines/delete-by-ids';
  static const String medicineImportStatus = 'medicines/import-status';

  // Terms & Conditions Endpoints
  static const String termsConditionsCreate = 'terms-conditions/create';
  static const String termsConditionsGetAll = 'terms-conditions/get-all';
  static const String termsConditionsUpdate = 'terms-conditions/update';
  static const String termsConditionsDelete = 'terms-conditions/delete';

  // Privacy Policy Endpoints
  static const String privacyPolicyCreate = 'privacy-policies/create';
  static const String privacyPolicyGetAll = 'privacy-policies/get-all';
  static const String privacyPolicyUpdate = 'privacy-policies/update';
  static const String privacyPolicyDelete = 'privacy-policies/delete';

  // Pharma Shop Endpoints
  static const String pharmaShopGetAll = 'auth/pharma-shop/get-all';
  static const String pharmaShopGetById = 'auth/pharma-shop/get-by';
  static const String pharmaShopUpdateById = 'auth/pharma-shop/update-by';
  static const String pharmaShopDeleteById = 'auth/pharma-shop/delete-by';

  // Customer Endpoints
  static const String customerGetAll = 'customers/get-all';
  static const String customerGetProfile = 'customers/profile';
  static const String customerUpdateProfile = 'customers/profile';
}
