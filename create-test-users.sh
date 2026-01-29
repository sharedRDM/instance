#!/usr/bin/env bash
# Create users for local testing: regular, admin, and curator

set -e

echo "Creating roles (if they don't exist)..."

# Create admin role if it doesn't exist
invenio roles create admin 2>/dev/null || echo "Role 'admin' already exists"

# Create curation moderation role if it doesn't exist
invenio roles create administration-rdm-records-curation 2>/dev/null || echo "Role 'administration-rdm-records-curation' already exists"

# Grant permissions to admin role
echo "Granting permissions to admin role..."
invenio access allow superuser-access role admin 2>/dev/null || echo "Permission already granted"

echo ""
echo "Creating users..."

# Create regular user
echo "Creating regular user: user@test.org (password: 123456)"
invenio users create user@test.org --password 123456 --active --confirm 2>/dev/null || echo "User 'user@test.org' already exists"

# Create admin user
echo "Creating admin user: admin@test.org (password: 123456)"
invenio users create admin@test.org --password 123456 --active --confirm 2>/dev/null || echo "User 'admin@test.org' already exists"
invenio roles add admin@test.org admin 2>/dev/null || echo "Role already assigned"

# Create curator user
echo "Creating curator user: curator@test.org (password: 123456)"
invenio users create curator@test.org --password 123456 --active --confirm 2>/dev/null || echo "User 'curator@test.org' already exists"
invenio roles add curator@test.org administration-rdm-records-curation 2>/dev/null || echo "Role already assigned"

echo ""
echo "Users created successfully!"
echo ""
echo "Login credentials:"
echo "  Regular user: user@test.org / 123456"
echo "  Admin user:   admin@test.org / 123456"
echo "  Curator user: curator@test.org / 123456"
