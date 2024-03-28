/// A configuration class to manage constants and settings for document handling within an application.
/// This class primarily deals with identifiers for recipe classifications and recipe documents,
/// and also manages a user identifier.

class DocumentsConfig {
  static String recipeClassify = "recipe_classify";
  static String recipe = "recipe";

  static String userId = "";

  static void setUserId(String? data) {
    userId = data ?? "";
  }
}
