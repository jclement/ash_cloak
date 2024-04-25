defmodule AshCloak.Test.Resource do
  @moduledoc false

  use Ash.Resource,
    domain: AshCloak.Test.Domain,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshCloak]

  ets do
    private?(true)
  end

  @attributes [:encrypted, :encrypted_always_loaded, :not_encrypted]
  actions do
    defaults([:read, :destroy, create: @attributes, update: @attributes])
  end

  cloak do
    vault(AshCloak.Test.Vault)
    attributes([:encrypted, :encrypted_always_loaded])
    decrypt_by_default([:encrypted_always_loaded])

    on_decrypt(fn resource, records, field, context ->
      send(self(), {:decrypting, resource, records, field, context})

      if Enum.any?(records, &(&1.not_encrypted == "dont allow decryption")) do
        {:error, "can't do it dude"}
      else
        :ok
      end
    end)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:not_encrypted, :string)
    attribute(:encrypted, :integer, public?: true)
    attribute(:encrypted_always_loaded, :map, public?: true)
  end
end
