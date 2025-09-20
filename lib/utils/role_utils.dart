// This file contains utility functions for managing user roles. 

// Function to check if a user has a specific role
bool hasRole(String userRole, List<String> roles) {
    return roles.contains(userRole);
}

// Function to check if a user is an admin
bool isAdmin(String userRole) {
    return userRole == 'admin';
}

// Function to check if a user is a viewer
bool isViewer(String userRole) {
    return userRole == 'viewer';
}

// Function to check if a user is an editor
bool isEditor(String userRole) {
    return userRole == 'editor';
}

// Function to get a list of available roles
List<String> getAvailableRoles() {
    return ['admin', 'editor', 'viewer'];
}