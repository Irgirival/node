## State Sync
```
sudo systemctl stop andromedad

cp $HOME/.odin/data/priv_validator_state.json $HOME/.odin/priv_validator_state.json.backup
andromedad tendermint unsafe-reset-all --home $HOME/.odin --keep-addr-book

SNAP_RPC="https://mainnet-odin-rpc.konsortech.xyz:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

peers="5a048cab1d183de5c465c56b29a16fd93a8bf9bd@mainnet-odin.konsortech.xyz:18656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.odin/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.odin/config/config.toml

mv $HOME/.odin/priv_validator_state.json.backup $HOME/.odin/data/priv_validator_state.json

sudo systemctl restart andromedad
sudo journalctl -u andromedad -f --no-hostname -o cat
```