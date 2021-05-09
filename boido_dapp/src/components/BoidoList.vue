<template>
    <div class="row">
        <BoidoCard v-for="(card, index) in cards" :key="index" :card="card" @buy="$emit('buy',$event)"  @trade="trade($event)">
        </BoidoCard>
    </div>
</template>

<script>
  import BoidoCard from './BoidoCard.vue'

  export default {
    props: {
      cards: {
        type: Array,
        required: true,
      },
    },
    components: {
      BoidoCard,
    },
  }
</script>
