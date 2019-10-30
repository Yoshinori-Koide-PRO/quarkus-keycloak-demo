#!/bin/sh

KC_CLIENT_ID=quarkus-front
KC_ISSUER=http://keycloak:8180/auth/realms/quarkus-quickstart

echo -e '# ↓ まずは "test" ユーザーでKeyCloakにログインし、アクセストークンを取得する'
KC_USERNAME=test
KC_PASSWORD=test

KC_RESPONSE=$( \
curl \
  -d "client_id=$KC_CLIENT_ID" \
  -d "username=$KC_USERNAME" \
  -d "password=$KC_PASSWORD" \
  -d "grant_type=password" \
  "$KC_ISSUER/protocol/openid-connect/token" \
)

echo -e '# ↓ は取得したアクセストークンの表示'
echo $KC_RESPONSE | jq -C .

KC_ACCESS_TOKEN=$(echo $KC_RESPONSE | jq -r .access_token)

echo -e "# ↓ 上記のアクセストークンで /data/user にアクセス"
curl -v -H "Authorization: Bearer $KC_ACCESS_TOKEN" http://quarkus:8082/data/user
echo -e '\n# ↑ ログイン成功！ちゃんと "test" ユーザーが認識されました。'
echo -e "# ↓ /data/admin にアクセスしてみると・・・"
curl -v -H "Authorization: Bearer $KC_ACCESS_TOKEN" http://quarkus:8082/data/admin
echo -e "\n# ↑ アクセスが拒否されました。"

echo -e "# ↓ 続いて admin ユーザーのトークンを取得"
KC_USERNAME=admin
KC_PASSWORD=test

KC_RESPONSE=$( \
curl \
  -d "client_id=$KC_CLIENT_ID" \
  -d "username=$KC_USERNAME" \
  -d "password=$KC_PASSWORD" \
  -d "grant_type=password" \
  "$KC_ISSUER/protocol/openid-connect/token" \
)
echo $KC_RESPONSE | jq -C .


KC_ACCESS_TOKEN=$(echo $KC_RESPONSE | jq -r .access_token)

echo -e '# ↓ "admin" トークンで /data/admin にアクセスしてみます。'
curl -v -H "Authorization: Bearer $KC_ACCESS_TOKEN" http://quarkus:8082/data/admin
echo -e '\n# ↑ アクセスできました！そしてユーザーが"admin" であることが確認できています。'
echo -e '# ↓ "admin" トークンで /data/user にアクセスしてみます。'
curl -v -H "Authorization: Bearer $KC_ACCESS_TOKEN" http://quarkus:8082/data/user
echo -e '\n# ↑ アクセスできました！そしてユーザーが"admin" であることが確認できています。'
